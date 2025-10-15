# Make it fetch latest tarball release since I'm too lazy to manually change it
set(PREFIX_DIR ${CMAKE_CURRENT_BINARY_DIR}/mpv-release-prefix)

ExternalProject_Add(mpv-release
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
    BUILD_COMMAND ${EXEC} LTO_JOB=1 ninja -C <BINARY_DIR>
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(mpv-release copy-versionfile
    DEPENDEES download
    DEPENDERS configure
    COMMAND bash -c "cp MPV_VERSION <INSTALL_DIR>/MPV_VERSION"
    WORKING_DIRECTORY <SOURCE_DIR>
    LOG 1
)

ExternalProject_Add_Step(mpv-release strip-binary
    DEPENDEES build
    ${mpv_add_debuglink}
    COMMENT "Stripping mpv binaries"
)

ExternalProject_Add_Step(mpv-release copy-binary
    DEPENDEES strip-binary
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/mpv.exe                           ${CMAKE_CURRENT_BINARY_DIR}/mpv-package/mpv.exe
    COMMENT "Copying mpv binaries and manual"
)

set(RENAME ${CMAKE_CURRENT_BINARY_DIR}/mpv-prefix/src/rename-stable.sh)
file(WRITE ${RENAME}
"#!/bin/bash
cd $1
TAG=$(cat MPV_VERSION)
mv -f $2 $3/mpv-\${TAG}-$4")

ExternalProject_Add_Step(mpv-release copy-package-dir
    DEPENDEES copy-binary
    COMMAND chmod 755 ${RENAME}
    COMMAND ${RENAME} <SOURCE_DIR> ${CMAKE_CURRENT_BINARY_DIR}/mpv-package ${CMAKE_BINARY_DIR} ${TARGET_CPU}${x86_64_LEVEL}
    COMMENT "Moving mpv package folder"
    LOG 1
)

cleanup(mpv-release copy-package-dir)
