ExternalProject_Add(mpv
    DEPENDS
        angle-headers
        ffmpeg
        fribidi
        lcms2
        libarchive # 直接读取压缩文件/http解压gzip数据
        libass
        # libdvdnav
        # libdvdread
        libiconv
        libjpeg
        libpng
        # luajit
        rubberband
        uchardet
        openal-soft
        # mujs
        vulkan
        shaderc
        libplacebo
        spirv-cross
        # vapoursynth
        libsdl2
    GIT_REPOSITORY https://github.com/mpv-player/mpv.git
    GIT_TAG v0.40.0
    SOURCE_DIR ${SOURCE_LOCATION}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 meson setup <BINARY_DIR> <SOURCE_DIR>
        --prefix=${MINGW_INSTALL_PREFIX}
        --libdir=${MINGW_INSTALL_PREFIX}/lib
        --cross-file=${MESON_CROSS}
        --default-library=shared
        --prefer-static
        -Dbuildtype=release
        -Ddebug=false
        -Db_ndebug=true
        -Doptimization=3
        -Dgpl=true
        -Db_lto=true
        ${mpv_lto_mode}
        -Dlibmpv=true
        
        -Dhtml-build=disabled
        -Dmanpage-build=disabled
        -Dpdf-build=disabled

        -Dcplugins=disabled
        -Dlua=disabled
        -Djavascript=disabled
        -Dshaderc=enabled

        -Dcuda-hwaccel=enabled
        -Dcuda-interop=enabled
        -Dd3d-hwaccel=enabled
        -Dd3d9-hwaccel=enabled
        -Dgl-dxinterop-d3d9=enabled

        -Dsdl2=enabled
        -Dlibarchive=enabled
        -Dlibbluray=enabled
        -Ddvdnav=disabled
        -Duchardet=enabled
        -Drubberband=enabled
        -Dlcms2=enabled
        -Diconv=enabled
        -Dspirv-cross=enabled

        -Dd3d11=enabled
        -Dopenal=enabled
        -Dvulkan=enabled
        ${mpv_gl}

        -Dwin32-threads=enabled
        -Dwin32-smtc=disabled
        -Dwasapi=disabled

        -Dvapoursynth=disabled
        -Dwayland=disabled
        -Dx11=disabled
        -Dalsa=disabled
        -Dpulse=disabled
        -Dc_args='-Wno-error=int-conversion'
    BUILD_COMMAND ${EXEC} LTO_JOB=1 PDB=1 ninja -C <BINARY_DIR>
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(mpv strip-binary
    DEPENDEES build
    ${mpv_add_debuglink}
    COMMENT "Stripping mpv binaries"
)

ExternalProject_Add_Step(mpv copy-binary
    DEPENDEES strip-binary
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/mpv.exe                           ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv.exe
    ${mpv_copy_debug}
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmpv-2.dll          ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/libmpv-2.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmpv.dll.a          ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/libmpv.dll.a
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/client.h       ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/include/mpv/client.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/stream_cb.h    ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/include/mpv/stream_cb.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/render.h       ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/include/mpv/render.h
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/include/mpv/render_gl.h    ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/include/mpv/render_gl.h
    COMMENT "Copying mpv binaries and manual"
)

set(RENAME ${CMAKE_CURRENT_BINARY_DIR}/mpv-prefix/src/rename.sh)
file(WRITE ${RENAME}
"#!/bin/bash
cd $1
GIT=$(git rev-parse --short=7 HEAD)
mv -f $2 $2-git-\${GIT}")

ExternalProject_Add_Step(mpv copy-package-dir
    DEPENDEES copy-binary
    COMMAND chmod 755 ${RENAME}

    COMMAND mv -f ${CMAKE_CURRENT_BINARY_DIR}/mpv-package ${CMAKE_BINARY_DIR}/mpv-package-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMAND mv -f ${CMAKE_CURRENT_BINARY_DIR}/mpv-debug ${CMAKE_BINARY_DIR}/mpv-package-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}/
    COMMAND ${RENAME} <SOURCE_DIR> ${CMAKE_BINARY_DIR}/mpv-package-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}

    COMMENT "Moving mpv package folder"
    LOG 1
)

force_rebuild_git(mpv)
force_meson_configure(mpv)
cleanup(mpv copy-package-dir)
