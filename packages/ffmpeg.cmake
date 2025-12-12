ExternalProject_Add(ffmpeg
    DEPENDS
        angle-headers
        amf-headers
        avisynth-headers
        ${nvcodec_headers}
        bzip2
        lame # mp3 encoder
        lcms2
        openssl
        # libssh
        # libsrt
        libass
        # libbluray
        # libdvdnav
        # libdvdread
        # libmfx # 不能和 libvpl 共存
        libmodplug
        libpng
        libsoxr
        libbs2b
        libvpx
        libwebp
        libzimg
        libmysofa
        libiconv
        fontconfig
        harfbuzz
        vulkan
        spirv-cross
        opus
        speex
        vorbis
        x264      # only encodec --- vvv ---
        ${ffmpeg_x265}
        xvidcore 
        libxml2
        libvpl
        libopenmpt # 模块音乐格式解码
        libjxl
        shaderc
        libplacebo
        # libzvbi       # 用于解析电视信号帧之间空白间隔内的信息
        # libaribcaption # 解析、转换日本 ARIB STD-B24 标准字幕格式
        aom         # av1 编解码，主要编码
        svtav1      # av1 编解码
        dav1d
        # vapoursynth  # python 扩展视频处理
        ${ffmpeg_uavs3d}
        ${ffmpeg_davs2}
        rubberband
        libva
        openal-soft
        fribidi
        
        # libmpv 放一起可能可以提供 ffmpeg autodetect，然后再控制导出符号给 libmpv 链接共享 ---
        libarchive
        libjpeg
        # luajit
        uchardet
        # mujs
        # vapoursynth
        # libsdl2
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    GIT_TAG n8.0.1
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    PATCH_COMMAND ${EXEC} git apply ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-*.patch
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw32
        --pkg-config-flags=--static
        --enable-cross-compile
        --cxx=${TARGET_ARCH}-clang++
        --cc=${TARGET_ARCH}-clang
        --nm=${TARGET_ARCH}-nm
        --strip=${TARGET_ARCH}-strip
        --ar=${TARGET_ARCH}-llvm-ar
        --ranlib=${TARGET_ARCH}-llvm-ranlib
        --stdc=c23
        --stdcxx=c++23
        --extra-cflags='${CFLAGS} -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types -ffunction-sections -fdata-sections'
        --extra-cxxflags='${CXXFLAGS} -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types -ffunction-sections -fdata-sections'
        --extra-ldflags='${LDFLAGS} '
        --extra-ldexeflags='-L/home/coolight/program/media/mpv-winbuild-cmake/build_x86_64/prebuild_lib -lmediaxx'
        --extra-libs='${ffmpeg_extra_libs} -lm'

        --enable-gpl
        --enable-nonfree
        --enable-version3

        --disable-debug
        --enable-shared
        --disable-static
        --enable-stripping
        --enable-runtime-cpudetect
        --enable-pic
        --enable-asm 
        --enable-inline-asm
        --enable-lto=full
        --enable-optimizations
        # --enable-hardcoded-tables

        --disable-doc
        --disable-htmlpages
        --disable-manpages
        --disable-podpages
        --disable-txtpages
        --disable-xmm-clobber-test
        --disable-neon-clobber-test
        --disable-version-tracking
        --disable-gray
        --disable-swscale-alpha
        
        --disable-vdpau
        --disable-appkit
        --disable-videotoolbox
        --disable-audiotoolbox
        --disable-linux-perf
        
        # program
        --disable-programs
        --enable-ffmpeg
        --enable-ffprobe

        --enable-avutil
        --enable-avcodec
        --enable-avfilter
        --enable-avformat
        --enable-avdevice
        --enable-swscale
        --enable-swresample

        --enable-hwaccels
        --enable-bsfs

        # protocols
        --disable-protocols
        --disable-protocol=ffrtmphttp,rtmp,rtmps,rtmpt,rtmpts,rtp,srtp,libsrt,libssh 
        --enable-protocol=async 
        --enable-protocol=cache 
        --enable-protocol=crypto 
        --enable-protocol=data 
        --enable-protocol=file 
        --enable-protocol=ftp 
        --enable-protocol=hls 
        --enable-protocol=pipe 
        --enable-protocol=http 
        --enable-protocol=httpproxy 
        --enable-protocol=https 
        --enable-protocol=subfile 
        --enable-protocol=tcp 
        --enable-protocol=tls 
        --enable-protocol=udp

        # 启用图片相关的封装器
        --enable-muxers

        --enable-demuxers

        --enable-decoders
        --disable-decoder=libaom_av1

        --enable-encoders

        --enable-parsers

        --enable-filters
        --disable-filter=afftdn
        --disable-filter=afwtdn
        --disable-filter=anlmdn
        --disable-filter=arnndn

        --enable-indevs
        --enable-outdevs
        --disable-indev=libcdio,v4l2,android_camera,decklink,dshow,gdigrab,iec61883,kmsgrab,libdc1394,vfwcap,xcbgrab,fbdev
        --disable-outdev=caca,fbdev,v4l2,avfoundation

        --disable-avisynth
        --disable-vapoursynth
        --disable-whisper
        --disable-libdvdnav
        --disable-libdvdread
        --disable-libsrt
        --disable-libzvbi
        --disable-libssh
        --disable-libmfx
        --disable-libaribcaption
        
        --enable-libspeex
        --enable-libbluray
        --enable-libxvid
        --enable-libmp3lame
        --enable-libsvtav1
        --enable-libaom
        --enable-libmodplug
        --enable-libopenmpt
        --enable-libx264
        --enable-libx265

        --enable-network
        --enable-amf
        --enable-libvpl
        --enable-d3d12va
        --enable-d3d11va
        --enable-ffnvcodec
        --enable-cuda
        --enable-cuda-llvm
        --enable-cuvid
        --enable-nvdec
        --enable-nvenc
        --disable-vulkan
        --disable-vulkan-static
        --disable-libshaderc
        --disable-libplacebo
        --disable-dxva2
        --disable-openal
        --disable-opengl
        --disable-vaapi
        --disable-vdpau
        --disable-appkit
        --disable-videotoolbox
        --disable-audiotoolbox
        --disable-linux-perf

        --disable-sdl2
        --enable-libuavs3d
        --enable-lcms2
        --enable-libopus
        --enable-libsoxr
        --enable-libvorbis
        --enable-libbs2b
        --enable-libvpx
        --enable-libwebp
        --enable-libdav1d
        --enable-libzimg
        --enable-openssl
        --enable-libxml2
        --enable-libjxl
        --enable-iconv
        --enable-zlib
        --enable-bzlib
        --enable-lzma
        ${ffmpeg_davs2_cmd}
        ${ffmpeg_uavs3d_cmd}
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(ffmpeg copy-binary
    DEPENDEES install
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libavfilter.a           ${CMAKE_SOURCE_DIR}/output/libavfilter.a
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libavutil.a             ${CMAKE_SOURCE_DIR}/output/libavutil.a
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libavdevice.a           ${CMAKE_SOURCE_DIR}/output/libavdevice.a
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libavcodec.a            ${CMAKE_SOURCE_DIR}/output/libavcodec.a
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libavformat.a           ${CMAKE_SOURCE_DIR}/output/libavformat.a
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libswresample.a         ${CMAKE_SOURCE_DIR}/output/libswresample.a
    COMMAND ${CMAKE_COMMAND} -E copy ${MINGW_INSTALL_PREFIX}/lib/libswscale.a            ${CMAKE_SOURCE_DIR}/output/libswscale.a

    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavfilter/avfilter.dll             ${CMAKE_SOURCE_DIR}/avfilter.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavutil/avutil.dll                 ${CMAKE_SOURCE_DIR}/avutil.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavdevice/avdevice.dll             ${CMAKE_SOURCE_DIR}/avdevice.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavcodec/avcodec.dll               ${CMAKE_SOURCE_DIR}/avcodec.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavformat/avformat.dll             ${CMAKE_SOURCE_DIR}/avformat.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswresample/swresample.dll         ${CMAKE_SOURCE_DIR}/swresample.dll
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswscale/swscale.dll               ${CMAKE_SOURCE_DIR}/swscale.dll

    COMMENT "Copying ffmpeg binaries and manual"
)

force_rebuild_git(ffmpeg)
force_meson_configure(ffmpeg)
# cleanup(ffmpeg copy-binary)
