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
        vulkan
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
        # aom         # av1 编解码，主要编码
        # svtav1      # av1 编解码
        dav1d
        # vapoursynth  # python 扩展视频处理
        ${ffmpeg_uavs3d}
        ${ffmpeg_davs2}
        rubberband
        libva
        openal-soft
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    GIT_TAG n8.0
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
        --enable-lto
        --enable-lto=thin
        --enable-hwaccels
        --enable-optimizations
        --enable-small

        --disable-gray
        --disable-swscale-alpha
        --disable-doc
        --disable-htmlpages
        --disable-manpages
        --disable-podpages
        --disable-txtpages
	    --disable-xmm-clobber-test
	    --disable-neon-clobber-test
        --disable-version-tracking
        
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
        --enable-muxer=image2pipe
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
        --disable-decoder=dvbsub
        --disable-decoder=dvdsub
        --disable-decoder=jacosub
        --disable-decoder=realtext
        --disable-decoder=stl
        --disable-decoder=microdvd
        --disable-decoder=mpl2

        --disable-encoders
        --enable-encoder=mjpeg
        --enable-encoder=ljpeg
        --enable-encoder=jpegls
        --enable-encoder=jpeg2000
        --enable-encoder=apng
        --enable-encoder=bmp
        --enable-encoder=dpx
        --enable-encoder=exr
        --enable-encoder=gif
        --enable-encoder=png
        --enable-encoder=pam
        --enable-encoder=pbm
        --enable-encoder=pcx
        --enable-encoder=pfm
        --enable-encoder=pgm
        --enable-encoder=pgmyuv
        --enable-encoder=phm
        --enable-encoder=png
        --enable-encoder=ppm
        --enable-encoder=fits
        --enable-encoder=tiff
        --enable-encoder=qoi
        --enable-encoder=sgi
        --enable-encoder=sunrast
        --enable-encoder=targa
        --enable-encoder=xbm
        --enable-encoder=xwd
        --enable-encoder=yuv4
        --enable-encoder=wbmp
        --enable-encoder=libwebp
        --enable-encoder=libwebp_anim

        --enable-parsers

        --disable-filters
	    --disable-filter=adeclick
	    --disable-filter=afftdn
	    --disable-filter=afwtdn
	    --disable-filter=anlmdn
	    --disable-filter=arnndn
	    --disable-filter=dcshift
	    --disable-filter=deesser
	    --disable-filter=fftdnoiz
	    --disable-filter=avsynctest
	    --disable-filter=fsync
	    --disable-filter=realtime
	    --disable-filter=areverse
	    --disable-filter=showinfo
	    --enable-filter=thumbnail
	    --enable-filter=select
	    --enable-filter=trim
	    --enable-filter=atrim
	    --enable-filter=fps
	    --enable-filter=movie
	    --enable-filter=metadata
	    --enable-filter=null
	    --enable-filter=nullsink
	    --enable-filter=nullsrc
	    --enable-filter=anull
	    --enable-filter=anullsink
	    --enable-filter=anullsrc
	    --enable-filter=adeclip
	    --enable-filter=acopy
	    --enable-filter=asetpts
	    --enable-filter=setpts
	    --enable-filter=amix
	    --enable-filter=amerge
	    --enable-filter=aresample
	    --enable-filter=asplit
	    --enable-filter=copy
	    --enable-filter=drawtext
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
	    --enable-filter=crossfeed
	    --enable-filter=spectrumsynth
	    --enable-filter=showwavespic
	    --enable-filter=afreqshift
	    --enable-filter=scale*
	    --enable-filter=vflip
	    --enable-filter=hflip
	    --enable-filter=overlay
	    --enable-filter=crop
	    --enable-filter=cropdetect
	    --enable-filter=format
	    --enable-filter=aformat
	    --enable-filter=noformat
	    --enable-filter=signalstats
	    --enable-filter=framepack
	    --enable-filter=framerate
	    --enable-filter=hwdownload
	    --enable-filter=hwupload

        --enable-indevs
        --enable-outdevs
        --disable-indev=libcdio
        --disable-indev=v4l2
        --disable-indev=android_camera
        --disable-indev=decklink
        --disable-indev=dshow
        --disable-indev=gdigrab
        --disable-indev=iec61883
        --disable-indev=kmsgrab
        --disable-indev=libdc1394
        --disable-indev=vfwcap
        --disable-indev=xcbgrab
        --disable-indev=fbdev
        --disable-outdev=caca
        --disable-outdev=fbdev

        --disable-libmfx
        --disable-avisynth
        --disable-vapoursynth
        --disable-whisper
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
        --disable-libaom

	    --enable-vulkan
        --enable-vulkan-static  
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
        --extra-cflags='-Wno-error=int-conversion -I<SOURCE_DIR>/compat/stdbit/'
        "--extra-libs='${ffmpeg_extra_libs} -lm -lshlwapi -lpthread -lcfgmgr32'"
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(ffmpeg copy-binary
    DEPENDEES install
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/ffmpeg.exe                            ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/ffmpeg.exe
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/ffprobe.exe                           ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/ffprobe.exe

    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavfilter/libavfilter.lib             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavfilter.lib
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavutil/libavutil.lib                 ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavutil.lib
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavdevice/libavdevice.lib             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavdevice.lib
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavcodec/libavcodec.lib               ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavcodec.lib
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavformat/libavformat.lib             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libavformat.lib
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswresample/libswresample.lib         ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libswresample.lib
    # COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswscale/libswscale.lib               ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/libswscale.lib

    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavfilter/avfilter.dll             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/avfilter.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavutil/avutil.dll                 ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/avutil.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavdevice/avdevice.dll             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/avdevice.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavcodec/avcodec.dll               ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/avcodec.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libavformat/avformat.dll             ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/avformat.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswresample/swresample.dll         ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/swresample.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libswscale/swscale.dll               ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-package/swscale.dll
    COMMENT "Copying ffmpeg binaries and manual"
)

set(RENAME ${CMAKE_CURRENT_BINARY_DIR}/ffmpeg-prefix/src/rename.sh)
file(WRITE ${RENAME}
"#!/bin/bash
cd $1
GIT=$(git rev-parse --short=7 HEAD)
rm -rf $2-git-\${GIT}
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
# cleanup(ffmpeg copy-package-dir)
