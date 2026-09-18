#!/usr/bin/env bash
# =============================================================================
# check-size.sh —— libmediaxx.dll 产物体检（体积 / 依赖 / 导出符号）
#
# 用途：每次编译完（或升级 ffmpeg/mpv/mediaxx 之后）花 1 秒确认：
#   1. 文件与各段大小是否异常膨胀
#   2. 是否意外依赖了非系统 DLL（libc++.dll / libstdc++-6.dll / libgcc_s_*.dll /
#      libwinpthread-1.dll / libmpv*.dll / avcodec*.dll … 一旦出现说明静态链接没生效，
#      随包发布时必须一起带上这些 DLL）
#   3. 导出符号是否与 ffmpeg-help/libmpv-win(-full).def 一致
#      （缺 = 运行期 GetProcAddress 失败；多 = 体积控制失效，按 mediaxx.cmake 的注释排查）
#   4. ICF/GC 实际折叠量的查看方法（见输出末尾）
#
# 用法：
#   ./check-size.sh                        # 体检同目录的 libmediaxx.dll
#   ./check-size.sh /path/libmediaxx.dll   # 指定 dll
#   ./check-size.sh /path/libmediaxx.dll /path/libmpv-win.def   # 指定符号表
#   XX_TOOLBIN=/path/clang_root/bin ./check-size.sh             # 指定 llvm 工具目录
#
# 退出码：0 = 正常（可能有 WARN）；1 = 有 FAIL（依赖异常 / 缺少导出符号）
# =============================================================================
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DLL="${1:-$script_dir/libmediaxx.dll}"
DEF="${2:-}"

# ── 工具查找 ────────────────────────────────────────────────────────────────
WORKSPACE_DIR="$(cd "$script_dir/.." 2>/dev/null && pwd || echo "$script_dir")"
TOOLBIN_CANDIDATES=("${XX_TOOLBIN:-}" "$WORKSPACE_DIR/clang_root/bin" "$WORKSPACE_DIR/build_x86_64_full/install/bin")

find_tool() {
    local name="$1" d
    for d in "${TOOLBIN_CANDIDATES[@]}"; do
        [ -n "$d" ] && [ -x "$d/$name" ] && { echo "$d/$name"; return 0; }
    done
    for d in "${TOOLBIN_CANDIDATES[@]}"; do
        [ -n "$d" ] && [ -x "$d/x86_64-w64-mingw32-${name#llvm-}" ] && { echo "$d/x86_64-w64-mingw32-${name#llvm-}"; return 0; }
    done
    command -v "$name" 2>/dev/null && return 0
    return 1
}

OBJDUMP="$(find_tool llvm-objdump || true)"
READOBJ="$(find_tool llvm-readobj || true)"
SIZE="$(find_tool llvm-size || true)"

fail_count=0
warn_count=0

say()   { printf '%s\n' "$*"; }
head1() { printf '\n== %s ==\n' "$*"; }
ok()    { printf '  [ OK ] %s\n' "$*"; }
warn()  { printf '  [WARN] %s\n' "$*"; warn_count=$((warn_count + 1)); }
fail()  { printf '  [FAIL] %s\n' "$*"; fail_count=$((fail_count + 1)); }

if [ ! -f "$DLL" ]; then
    say "找不到 DLL: $DLL"
    say "用法: $0 [dll路径] [def路径]"
    exit 2
fi
if [ -z "$OBJDUMP" ]; then
    say "找不到 llvm-objdump，请用 XX_TOOLBIN=<clang_root/bin> 指定 llvm 工具目录"
    exit 2
fi

# 完整的 objdump -p 输出缓存（依赖、导出两处共用）
pe_dump="$(mktemp)"; trap 'rm -f "$pe_dump"' EXIT
"$OBJDUMP" -p "$DLL" > "$pe_dump" 2>/dev/null || true

# ── 1. 文件 / 段大小 ────────────────────────────────────────────────────────
head1 "体积：$DLL"
ls -l "$DLL" | awk '{ printf "  文件大小 : %8.2f MiB (%s bytes)\n", $5/1048576, $5 }'
if [ -n "$SIZE" ]; then
    "$SIZE" -A "$DLL" 2>/dev/null | awk '
        /^\./   { printf "  %-16s %8.2f MiB\n", $1, $2/1048576 }
        /Total/ { printf "  %-16s %8.2f MiB\n", "总计", $2/1048576 }'
fi

# ── 2. 依赖的 DLL ───────────────────────────────────────────────────────────
head1 "依赖检查（静态链接正确时应当只有 Windows 系统 DLL）"

# 允许出现的系统 DLL（大小写不敏感；api-ms-win-* 为 Windows 的转发 DLL）
SYSTEM_PATTERN='^(kernel32|kernelbase|ntdll|msvcrt|ucrtbase|shcore|api-ms-win-[a-z0-9-]+|user32|gdi32|gdiplus|advapi32|shell32|shlwapi|ole32|oleaut32|combase|ws2_32|bcrypt|bcryptprimitives|crypt32|secur32|iphlpapi|dnsapi|version|winmm|avrt|dwmapi|uxtheme|d3d11|dxgi|d3dcompiler_[0-9]+|d2d1|setupapi|cfgmgr32|powrprof|dbghelp|userenv|wldap32|comctl32|nvapi|nvcuda|mfplat|mfuuid|propsys|rpcrt4|wininet|urlmon|normaliz|wintrust|imm32|mpr|opengl32)\.dll$'

awk '/DLL Name: /{ print $3 }' "$pe_dump" | sort -u > "$pe_dump.deps"
total_deps="$(grep -c . "$pe_dump.deps" || true)"
if [ "$total_deps" -eq 0 ]; then
    warn "未解析到任何依赖（objdump 输出异常？）"
else
    while IFS= read -r dep; do
        [ -z "$dep" ] && continue
        if echo "$dep" | grep -qiE "$SYSTEM_PATTERN"; then
            ok "$dep（系统）"
        else
            fail "$dep（非系统 DLL！需随程序一起分发，或检查静态链接是否失效）"
        fi
    done < "$pe_dump.deps"
    say "  ---- 共 $total_deps 个依赖"
fi

# ── 3. 导出符号 vs .def ─────────────────────────────────────────────────────
head1 "导出符号检查"

# 从 def 中取符号名（exe-help 里的文件都是 CRLF，需先去掉 \r）
def_symbols() {
    sed 's/\r$//' "$1" | sed -n '/^EXPORTS/,$p' | sed '1d' | sed 's/;.*//' | awk 'NF{print $1}' | sort -u
}

exp_tmp="$(mktemp)"
if [ -n "$READOBJ" ] && "$READOBJ" --coff-exports "$DLL" >/dev/null 2>&1; then
    "$READOBJ" --coff-exports "$DLL" | awk '/^ +Name: /{ print $2 }' | sort -u > "$exp_tmp"
else
    # 退化为 objdump -p 的 [Ordinal/Name Pointer] Table
    sed -n '/\[Ordinal\/Name Pointer\] Table/,/^[[:space:]]*$/p' "$pe_dump" \
        | sed -n 's/^[[:space:]]*\[[[:space:]]*[0-9]*\][[:space:]]*\([^[:space:]]*\).*$/\1/p' | sort -u > "$exp_tmp"
fi
say "  导出符号总数 : $(wc -l < "$exp_tmp" | tr -d ' ')"

# 自动挑选 def：优先用户指定；否则在 libmpv-win.def / libmpv-win-full.def 中选与导出集合交集更大的
if [ -z "$DEF" ]; then
    best_hit=-1
    for cand in "$WORKSPACE_DIR/source/mediaxx/src/ffmpeg-help/libmpv-win.def" \
                "$WORKSPACE_DIR/source/mediaxx/src/ffmpeg-help/libmpv-win-full.def"; do
        [ -f "$cand" ] || continue
        hit="$(comm -12 "$exp_tmp" <(def_symbols "$cand") | grep -c . || true)"
        if [ "$hit" -gt "$best_hit" ]; then best_hit="$hit"; DEF="$cand"; fi
    done
fi

if [ -n "$DEF" ] && [ -f "$DEF" ]; then
    def_tmp="$(mktemp)"
    def_symbols "$DEF" > "$def_tmp"
    say "  对比符号表   : $DEF（$(wc -l < "$def_tmp" | tr -d ' ') 个）"

    missing="$(comm -23 "$def_tmp" "$exp_tmp")"
    extra="$(comm -13 "$def_tmp" "$exp_tmp")"
    if [ -n "$missing" ]; then
        fail "缺少 $(printf '%s\n' "$missing" | grep -c .) 个 def 中声明的导出（运行期 GetProcAddress 会失败）:"
        printf '%s\n' "$missing" | sed 's/^/         /' | head -30
    else
        ok "def 中声明的符号全部已导出"
    fi
    if [ -n "$extra" ]; then
        warn "多出 $(printf '%s\n' "$extra" | grep -c .) 个未在 def 中声明的导出（体积控制失效），前 30 个:"
        printf '%s\n' "$extra" | sed 's/^/         /' | head -30
    else
        ok "没有多余导出"
    fi
    rm -f "$def_tmp"
else
    warn "未找到 .def 符号表，跳过对比（可用第 2 个参数手动指定）"
fi

# ── 4. 结论 ─────────────────────────────────────────────────────────────────
head1 "结论"
say "  FAIL: $fail_count   WARN: $warn_count"
say ""
say "  想量化 ICF/GC 折叠量（判断体积还能不能继续压）时，用下面任一方式重新链接："
say "    a) 在 packages/mediaxx.cmake 的 CMAKE_SHARED_LINKER_FLAGS 里临时追加"
say "       -Wl,--print-icf-sections -Wl,--print-gc-sections"
say "    b) 或在配置工程时追加 -DLLD_FLAGS='--print-icf-sections --print-gc-sections'"
say "       （LLD_FLAGS 会写进 clang_root/bin/x86_64-w64-mingw32-ld 包装脚本，改完需要重跑链接）"

[ "$fail_count" -eq 0 ] || exit 1
exit 0
