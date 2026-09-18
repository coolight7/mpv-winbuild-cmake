ExternalProject_Add(mpv
    DEPENDS
        ffmpeg
        libass
        libplacebo
    # 源码说明：SOURCE_DIR 使用 ${SOURCE_LOCATION}（= SINGLE_SOURCE_LOCATION/mpv），
    # 该目录必须是 mediaxx 的 mpv fork 分支（含 audio-frame-fft / audio_fft 等自研能力），
    # 不要再给 mpv 加 PATCH_COMMAND —— 改动都已经在 fork 分支里了。
    # 要求要点（fork 的 meson.build）：libass、libplacebo 为必选依赖。
    GIT_REPOSITORY https://github.com/coolight7/mpv.git
    # GIT_TAG <fork 的分支或 commit>
    SOURCE_DIR ${SOURCE_LOCATION}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 meson setup <BINARY_DIR> <SOURCE_DIR>
        --prefix=${MINGW_INSTALL_PREFIX}
        --libdir=${MINGW_INSTALL_PREFIX}/lib
        --cross-file=${MESON_CROSS}
        --default-library=static
        -Dc_args='-Wno-error=int-conversion -ffunction-sections -fdata-sections'
        -Dbuildtype=release
        -Db_lto=true
        # meson 的 b_lto_mode 只有 default / thin 两个取值，default 对 clang 就是 -flto（full LTO），
        # 与 ffmpeg(--enable-lto=full)、各 CMake 包(toolchain 基础参数 -flto)保持一致；
        # 想统一改 thin 时这里改成 thin
        -Db_lto_mode=default
        -Ddebug=false
        -Db_ndebug=true
        -Doptimization=3
        -Dlibmpv=true
        -Dcplayer=false
        -Dgpl=false
        -Dbuild-date=false
        
        -Dhtml-build=disabled
        -Dmanpage-build=disabled
        -Dpdf-build=disabled

        -Dcplugins=disabled
        -Dlua=disabled
        -Djavascript=disabled

        -Ddvdnav=disabled
        -Dvapoursynth=disabled
        -Dlibbluray=disabled
        -Duchardet=enabled
        -Diconv=enabled
        -Dlibarchive=enabled
        -Drubberband=enabled
        -Dlcms2=enabled

        -Dwin32-smtc=disabled
        -Dwin32-threads=enabled
        
        -Dcaca=disabled
        -Dsixel=disabled
        -Dwayland=disabled
        -Dx11=disabled
        -Dalsa=disabled
        -Dpulse=disabled
        -Dsdl2-audio=disabled
        -Dsdl2-video=disabled
        -Dopenal=disabled

        -Dwasapi=enabled

        -Dvulkan=disabled
        # -Dshaderc=enabled
        # -Dspirv-cross=enabled
        -Dd3d11=enabled
        -Ddirect3d=disabled
        -Degl-angle=enabled
        -Dgl=enabled
        -Dgl-dxinterop-d3d9=disabled
        -Dvaapi-win32=disabled
        
        -Dcuda-hwaccel=enabled
        -Dcuda-interop=enabled
        -Dd3d-hwaccel=enabled
        -Dd3d9-hwaccel=disabled

    BUILD_COMMAND ${EXEC} LTO_JOB=1 PDB=1 ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(mpv copy-binary
    DEPENDEES build
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmpv-2.dll               ${CMAKE_SOURCE_DIR}/output/libmpv-2.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmpv.dll.a               ${CMAKE_SOURCE_DIR}/output/libmpv.dll.a
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/client.h         ${CMAKE_SOURCE_DIR}/output/include/mpv/client.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/stream_cb.h      ${CMAKE_SOURCE_DIR}/output/include/mpv/stream_cb.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/render.h         ${CMAKE_SOURCE_DIR}/output/include/mpv/render.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/render_gl.h      ${CMAKE_SOURCE_DIR}/output/include/mpv/render_gl.h
    
    # COMMAND ${CMAKE_SOURCE_DIR}/clang_root/bin/llvm-strip --strip-all        ${CMAKE_SOURCE_DIR}/output/libmpv-2.dll

    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/help/create_comm_syms.sh    ${CMAKE_SOURCE_DIR}/output/create_comm_syms.sh
    COMMAND chmod 755 ${CMAKE_SOURCE_DIR}/output/create_comm_syms.sh
    # d3dcompiler_43.dll
    COMMENT "Copying mpv binaries and manual"
)

# set(LIBMPV_PC ${MINGW_INSTALL_PREFIX}/lib/pkgconfig/libmpv.pc)
# file(WRITE ${LIBMPV_PC}
# "prefix=${MINGW_INSTALL_PREFIX}
# includedir=\${prefix}/include
# libdir=\${prefix}/lib

# Name: libmpv
# Description: libmpv
# Version: 0.40.0
# Requires: 
# Libs: -L\${libdir} -lmpv    -lplacebo -lshlwapi -lversion   -lavfilter -lavcodec -lavutil -lavdevice -lavformat -lswresample -lswscale   -larchive -lz -lbz2 -llzma -llzo2 -lzstd -lbcrypt -lcrypto -liconv -lcharset -lxml2 -lpthread -liconv -lbcrypt -lz   -ljpeg   -luchardet -lstdc++   -lm
# Cflags: -I\${includedir}/mpv -DPL_STATIC
# ")

# # ExternalProject_Add_Step(mpv gendef
# #     DEPENDEES copy-binary
# #     COMMAND chmod 755 ${CMAKE_SOURCE_DIR}/output/create_comm_syms.sh
# #     COMMAND ${CMAKE_SOURCE_DIR}/output/create_comm_syms.sh
# #     COMMENT ""
# #     LOG 1
# # )

# force_rebuild_git(mpv)
force_meson_configure(mpv)
# cleanup(mpv copy-binary)
