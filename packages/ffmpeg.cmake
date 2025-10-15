ExternalProject_Add(ffmpeg
    DEPENDS
        amf-headers
        avisynth-headers
        ${nvcodec_headers}
        bzip2
        lame
        lcms2
        openssl
        libssh
        libsrt
        libass
        libbluray
        # libdvdnav
        # libdvdread
        libmodplug
        libpng
        libsoxr
        libbs2b
        libvpx
        libwebp
        libzimg
        libmysofa
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
        libopenmpt # 模块音乐格式解码
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
    GIT_TAG "n7.1.2"
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
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

        --disable-gpl # --enable-gpl
        --disable-nonfree
        --disable-version3
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
        --disable-ffplay
        --enable-ffmpeg
        --enable-ffprobe

        --enable-avutil
        --enable-avcodec
        --enable-avfilter
        --enable-avformat
        --enable-avdevice
        --enable-swscale
        --enable-swresample

        --enable-network
        --enable-amf
        --enable-dxva2
        --enable-libmfx
        --enable-libuavs3d
        --enable-d3d11va
        --enable-openal
        --enable-opengl
        --enable-vaapi

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
        --enable-protocol=libsrt
        --enable-protocol=subfile
        --enable-protocol=tcp
        --enable-protocol=tls
        --enable-protocol=udp
        --enable-protocol=libssh

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

        --enable-decoders
        --disable-decoder=libaom_av1

        --disable-encoders
        --enable-encoder=mjpeg
        --enable-encoder=ljpeg
        --enable-encoder=jpegls
        --enable-encoder=jpeg2000
        --enable-encoder=png
        --enable-encoder=bmp
        --enable-encoder=gif
        --enable-encoder=apng
        --enable-encoder=tiff
        --enable-encoder=libwebp
        --enable-encoder=libwebp_anim
        --enable-encoder=ppm
        --enable-encoder=pgm
        --enable-encoder=pcx
        --enable-encoder=sgi
        --enable-encoder=sunrast
        --enable-encoder=targa
        --enable-encoder=wbmp
        --enable-encoder=xbm
        --enable-encoder=xwd

        --enable-parsers

        --disable-filters

        --enable-filter=thumbnail
        --enable-filter=thumbnail_cuda
        --enable-filter=movie

        --enable-filter=avsynctest
        --enable-filter=fsync
        --enable-filter=metadata
        --enable-filter=null
        --enable-filter=nullsink
        --enable-filter=nullsrc
        --enable-filter=realtime

        --enable-filter=acopy
        --enable-filter=amix
        --enable-filter=amerge
        --enable-filter=areverse
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
        --enable-filter=adeclick
        --enable-filter=adeclip
        --enable-filter=afftdn
        --enable-filter=afwtdn
        --enable-filter=anlmdn
        --enable-filter=arnndn
        --enable-filter=dcshift
        --enable-filter=deesser
        --enable-filter=fftdnoiz
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

        --enable-avisynth
        --disable-vapoursynth
        --enable-libass
        --enable-libbluray
        --disable-libdvdnav
        --disable-libdvdread
        --enable-libfreetype
        --enable-libfribidi
        --enable-libfontconfig
        --enable-libharfbuzz
        --enable-libmodplug
        --enable-libopenmpt
        --enable-libmp3lame
        --enable-lcms2
        --enable-libopus
        --enable-libsoxr
        --enable-libspeex
        --enable-libvorbis
        --enable-libbs2b
        --enable-librubberband
        --enable-libvpx
        --enable-libwebp
        --disable-libx264
        --disable-libx265
        --enable-libaom
        --enable-libsvtav1
        --enable-libdav1d
        ${ffmpeg_davs2_cmd}
        ${ffmpeg_uavs3d_cmd}
        --disable-libxvid
        --enable-libzimg
        --enable-openssl
        --enable-libxml2
        --enable-libmysofa
        --enable-libssh
        --enable-libsrt
        --enable-libvpl
        --enable-libjxl
        --enable-libplacebo
        --enable-libshaderc
        --disable-libzvbi
        --disable-libaribcaption
        ${ffmpeg_cuda}
        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'" # -lstdc++ / -lc++ needs by libjxl and shaderc
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
