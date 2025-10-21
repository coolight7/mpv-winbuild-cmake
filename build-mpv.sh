# 直接进入容器内，按 yaml 手动编译
# act -v -W ".github/workflows/llvm_clang.yml" --job "build_llvm" --pull false --reuse -P ubuntu-latest=ghcr.io/shinchiro/archlinux:latest

# 留意 自动 git clone ffmpeg 版本是否正确

export BIT=x86_64
export mpv_ver=0.40.0

export http_proxy=http://172.29.48.1:7897
export https_proxy=http://172.29.48.1:7897
export no_proxy=localhost,127.0.0.1

git config --global user.name "github-actions"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
git config --global --add safe.directory $PWD

# 删 ffmpeg/libav 系列的不能直接 rm libav*，win自身有一个 libavrt 的库！！！

# 不能重复执行，否则 patch 会重复执行导致错误
cmake -DTARGET_ARCH=x86_64-w64-mingw32 \
    -DCMAKE_INSTALL_PREFIX="$PWD/clang_root" \
    -DCOMPILER_TOOLCHAIN=clang \
    -DGCC_ARCH=x86-64 \
    -DSINGLE_SOURCE_LOCATION="$PWD/src_packages_mpv" \
    -DMINGW_INSTALL_PREFIX="$PWD/build_x86_64/x86_64-w64-mingw32" \
    -G Ninja -B build_x86_64_mpv -S .

if [ $? -ne 0 ]; then
    echo "命令执行失败"
    exit 77
fi

cd build_x86_64_mpv/

# 编译中途失败了修好直接再运行这一句就可以了
ninja mpv

# 如果编译失败了，可以直接进入 build_x86_64_mpv/packages/对应包/src/xxx-build/ 内手动按 xxx.cmake 编译 make && make install