ExternalProject_Add(ffmpeg
    DEPENDS
        amf-headers
        avisynth-headers
        ${nvcodec_headers}
        bzip2
        # lame # mp3 encoder
        lcms2
        openssl
        # libssh
        # libsrt
        libass
        # libbluray
        # libdvdnav
        # libdvdread
        # libmodplug
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
        opus
        speex
        vorbis
        # x264      # only encodec --- vvv ---
        # ${ffmpeg_x265}
        # xvidcore 
        libxml2
        libvpl
        # libopenmpt # 模块音乐格式解码
        libjxl
        shaderc
        libplacebo
        # libzvbi       # 用于解析电视信号帧之间空白间隔内的信息
        # libaribcaption # 解析、转换日本 ARIB STD-B24 标准字幕格式
        aom         # av1 编解码
        svtav1      # av1 编解码
        dav1d
        # vapoursynth  # python 扩展视频处理
        ${ffmpeg_uavs3d}
        ${ffmpeg_davs2}
        rubberband
        libva
        openal-soft
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    GIT_TAG n7.1.2
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

        --enable-gpl # --enable-gpl
        --enable-nonfree
        --enable-version3

        --disable-debug
        --disable-shared
        --enable-static
        --enable-stripping
        --enable-runtime-cpudetect
        --enable-small
        --enable-hwaccels
        --enable-optimizations

        --disable-doc
        --disable-postproc
        --disable-gray
        --disable-swscale-alpha
        
        --disable-vdpau
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

        --enable-bsfs
        --disable-bsf=mov2textsub
        --disable-bsf=text2movsub

        # protocols
        --disable-protocols
        --disable-protocol=ffrtmphttp
        --disable-protocol=rtmp
        --disable-protocol=rtmps
        --disable-protocol=rtmpt
        --disable-protocol=rtmpts
        --disable-protocol=rtp
        --disable-protocol=srtp
        --disable-protocol=libsrt
        --disable-protocol=libssh
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
        --disable-muxers
        --enable-muxer=image2
        --enable-muxer=mjpeg
        --enable-muxer=mpjpeg
        --enable-muxer=apng
        --enable-muxer=avif
        --enable-muxer=fits
        --enable-muxer=gif
        --enable-muxer=ico
        --enable-muxer=webp

        --enable-demuxers
        --disable-demuxer=vobsub
        --disable-demuxer=dvbsub
        --disable-demuxer=dvbtxt
        --disable-demuxer=mpl2
        --disable-demuxer=aqtitle
        --disable-demuxer=jacosub
        --disable-demuxer=realtext
        --disable-demuxer=tedcaptions
        --disable-demuxer=stl
        --disable-demuxer=ace
        --disable-demuxer=gxf
        --disable-demuxer=live_flv
        --disable-demuxer=lxf
        --disable-demuxer=microdvd
        --disable-demuxer=rtp
        --disable-demuxer=rtsp

        --enable-decoders
        --disable-decoder=libaom_av1
        --disable-decoder=aac_mediacodec
        --disable-decoder=amrnb_mediacodec
        --disable-decoder=amrwb_mediacodec
        --disable-decoder=h264_mediacodec
        --disable-decoder=hevc_mediacodec
        --disable-decoder=mp3_mediacodec
        --disable-decoder=opus_mediacodec
        --disable-decoder=vorbis_mediacodec
        --disable-decoder=mpeg2_mmal
        --disable-decoder=h264_mmal
        --disable-decoder=vp8_mmal
        --disable-decoder=h263_v4l2m2m
        --disable-decoder=h264_v4l2m2m
        --disable-decoder=hevc_v4l2m2m
        --disable-decoder=mpeg1_v4l2m2m
        --disable-decoder=vc1_v4l2m2m
        --disable-decoder=mpeg2_v4l2m2m
        --disable-decoder=mpeg4_v4l2m2m
        --disable-decoder=vp8_v4l2m2m
        --disable-decoder=vp9_v4l2m2m
        --disable-decoder=dvbsub
        --disable-decoder=dvdsub
        --disable-decoder=jacosub
        --disable-decoder=realtext
        --disable-decoder=stl
        --disable-decoder=microdvd
        --disable-decoder=mpl2

        --disable-encoders
        --enable-encoder=mjpeg
        --disable-encoder=ljpeg
        --disable-encoder=jpegls
        --disable-encoder=jpeg2000
        --enable-encoder=png
        --enable-encoder=bmp
        --enable-encoder=gif
        --enable-encoder=apng
        --enable-encoder=tiff
        --enable-encoder=libwebp
        --enable-encoder=libwebp_anim
        --disable-encoder=ppm
        --disable-encoder=pgm
        --disable-encoder=pcx
        --disable-encoder=sgi
        --disable-encoder=sunrast
        --disable-encoder=targa
        --enable-encoder=wbmp
        --disable-encoder=xbm
        --disable-encoder=xwd

        --enable-parsers

        --disable-filters

        --enable-filter=thumbnail
        --enable-filter=thumbnail_cuda
        --disable-filter=movie

        --disable-filter=avsynctest
        --disable-filter=fsync
        --enable-filter=metadata
        --enable-filter=null
        --enable-filter=nullsink
        --enable-filter=nullsrc
        --disable-filter=realtime

        --enable-filter=acopy
        --enable-filter=amix
        --enable-filter=amerge
        --disable-filter=areverse
        --enable-filter=aresample
        --enable-filter=asplit
        --enable-filter=atrim
        --enable-filter=volume
        --enable-filter=volumedetect
        --enable-filter=acompressor
        --enable-filter=adrc
        --enable-filter=dynaudnorm
        --enable-filter=limiter
        --enable-filter=mcompand
        --enable-filter=anequalizer
        --enable-filter=bandpass
        --enable-filter=bandreject
        --enable-filter=bass
        --enable-filter=equalizer
        --enable-filter=highpass
        --enable-filter=highshelf
        --enable-filter=lowpass
        --enable-filter=lowshelf
        --enable-filter=midequalizer
        --enable-filter=tiltshelf
        --enable-filter=aecho
        --enable-filter=aphaser
        --enable-filter=bs2b
        --enable-filter=crystalizer
        --enable-filter=flanger
        --enable-filter=haas
        --enable-filter=headphone
        --enable-filter=extrastereo
        --enable-filter=sofalizer
        --enable-filter=stereotools
        --enable-filter=stereowiden
        --enable-filter=surround
        --enable-filter=tremolo
        --enable-filter=vibrato
        --enable-filter=virtualbass
        --disable-filter=adeclick
        --disable-filter=adeclip
        --disable-filter=afftdn
        --disable-filter=afwtdn
        --disable-filter=anlmdn
        --disable-filter=arnndn
        --disable-filter=dcshift
        --disable-filter=deesser
        --disable-filter=fftdnoiz
        --enable-filter=ebur128
        --enable-filter=loudnorm
        --enable-filter=replaygain
        --enable-filter=silencedetect
        --enable-filter=silenceremove
        --enable-filter=aexciter
        --enable-filter=amplify
        --enable-filter=apulsator
        --enable-filter=atempo
        --enable-filter=dialoguenhance
        --enable-filter=rubberband
        --enable-filter=sinc
        --enable-filter=sine
        --enable-filter=spectrumsynth

        --enable-avdevice
        --disable-indevs
        --enable-outdev=opengl
        --enable-outdev=sdl2

        --disable-libmfx
        --disable-avisynth
        --disable-vapoursynth
        --disable-libbluray
        --disable-libdvdnav
        --disable-libdvdread
        --disable-libmodplug
        --disable-libopenmpt
        --disable-libx264
        --disable-libx265
        --disable-libsrt
        --disable-libzvbi
        --disable-libaribcaption
        --disable-libxvid
        --disable-libmp3lame
        --disable-libssh
        --disable-libspeex
        
        --disable-libsvtav1

        --enable-network
        --enable-amf
        --enable-dxva2
        --enable-libuavs3d
        --enable-d3d11va
        --enable-openal
        --enable-opengl
        --enable-vaapi
        --enable-libass
        --enable-libfreetype
        --enable-libfribidi
        --enable-libfontconfig
        --enable-libharfbuzz
        --enable-lcms2
        --enable-libopus
        --enable-libsoxr
        --enable-libvorbis
        --enable-libbs2b
        --enable-librubberband
        --enable-libvpx
        --enable-libwebp
        --enable-libaom
        --enable-libdav1d
        --enable-libzimg
        --enable-openssl
        --enable-libxml2
	    --enable-iconv
        --enable-libmysofa
        --enable-libvpl
        --enable-libjxl
        --enable-libplacebo
        --enable-libshaderc
        ${ffmpeg_davs2_cmd}
        ${ffmpeg_uavs3d_cmd}
        ${ffmpeg_cuda}
        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'" # -lstdc++ / -lc++ needs by libjxl and shaderc
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(ffmpeg copy-binary
    DEPENDEES install
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/ffmpeg.exe                            ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/ffmpeg.exe
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/ffprobe.exe                           ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/ffprobe.exe

    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavfilter/libavfilter.a             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavfilter.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswresample/libswresample.a         ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libswresample.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavutil/libavutil.a                 ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavutil.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavdevice/libavdevice.a             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavdevice.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswscale/libswscale.a               ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libswscale.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavcodec/libavcodec.a               ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavcodec.a
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavformat/libavformat.a             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavformat.a
    COMMENT "Copying ffmpeg binaries and manual"
)

set(RENAME ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-prefix/src/rename.sh)
file(WRITE ${RENAME}
"#!/bin/bash
cd $1
GIT=$(git rev-parse --short=7 HEAD)
mv -f $2 $2-git-\${GIT}")

ExternalProject_Add_Step(ffmpeg copy-package-dir
    DEPENDEES copy-binary
    COMMAND chmod 755 ${RENAME}

    COMMAND mv -f ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package ${CMAKE_BINARY_DIR}/ffmpeg-package-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMAND ${RENAME} <SOURCE_DIR> ${CMAKE_BINARY_DIR}/ffmpeg-package-${TARGET_CPU}${x86_64_LEVEL}-${BUILDDATE}
    COMMENT "Moving ffmpeg package folder"
    LOG 1
)

force_rebuild_git(ffmpeg)
force_meson_configure(ffmpeg)
cleanup(ffmpeg copy-package-dir)
