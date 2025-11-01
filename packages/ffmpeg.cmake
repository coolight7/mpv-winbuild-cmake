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

        --enable-indevs
        --enable-outdevs
        --disable-indev=libcdio,v4l2,android_camera,decklink,dshow,gdigrab,iec61883,kmsgrab,libdc1394,vfwcap,xcbgrab,fbdev
        --disable-outdev=caca,fbdev,v4l2,avfoundation

        --enable-bsfs
	    --disable-bsf=mov2textsub,text2movsub

        --enable-decoders
        --disable-decoder=libaom_av1
	    --disable-decoder=srt,ass,ssa,realtext,libzvbi_teletext,movtext,bintext,dvbsub,dvdsub,subrip,jacosub,subviewer,subviewer1,pgssub,xsub,ccaption,libaribb24,libaribcaption,microdvd,sami,stl,webvtt
	    --disable-decoder=libgme,libmodplug,libopenmpt
	    --disable-decoder=indeo2,indeo3,indeo4,indeo5,cinepak
	    --disable-decoder=bethsoftvid,idcin,roq_*,smacker,xan_*,c93,vcr1,vcr2,vqa,bink,binkaudio_dct,binkaudio_rdft,thp,dfa,ipu
	    --disable-decoder=truespeech,tiertexseqvideo,nellymoser,qdmc,qdmc_at,qdm2,qdm2_at,g723_1,g728,sipr,ws_snd1,tmv,bonk,shorten,sol_dpcm

        --disable-encoders
        --enable-encoder=mjpeg*
        --enable-encoder=ljpeg
        --enable-encoder=jpegls
        --enable-encoder=jpeg2000
        --enable-encoder=anull,vnull

        --enable-parsers

        --disable-muxers
        --enable-muxer=image2*,mjpeg,mpjpeg,smjpeg,null

        --enable-demuxers
        --disable-demuxer=lrc,srt,ass,realtext,mpsub,dvbtxt,dvdsub,vobsub,subrip,aqtitle,jacosub,subviewer,subviewer1,ccaption,microdvd,sami,stl,webvtt,psb,mpl2
	    --disable-demuxer=rtp,rtsp,libgme,libmodplug,libopenmpt
	    --disable-demuxer=bethsoftvid,smacker,bink,binka,vqa,thp,roq,tiertexseq,c93,lvf,nuv,dfa,dcstr,ipu,sol,sds,shorten,bonk,tmv,sbg,mgsts,g723_1,g728,lmlm4

        --disable-filters
        --enable-filter=format
        --enable-filter=aformat
        --enable-filter=noformat
        --enable-filter=hwdownload
        --enable-filter=hwupload
        --enable-filter=copy
        --enable-filter=showwavespic
        --enable-filter=acompressor
        --enable-filter=alimiter
        --enable-filter=atrim
        --enable-filter=aecho
        --enable-filter=acopy
        --enable-filter=amovie
        --enable-filter=apulsator
        --enable-filter=bs2b
        --enable-filter=bass
        --enable-filter=compand
        --enable-filter=dialoguenhance
        --enable-filter=equalizer
        --enable-filter=loudnorm
        --enable-filter=metadata
        --enable-filter=pan
        --enable-filter=stereowiden
        --enable-filter=stereotools
        --enable-filter=rubberband
        --enable-filter=volume
        --enable-filter=volumedetect
        --enable-filter=null,nullsink,nullsrc,anull,anullsink,anullsrc
        --enable-filter=amix
        --enable-filter=aselect
        --enable-filter=atempo
        --enable-filter=aresample
        --enable-filter=sinc
        --enable-filter=sine

        # protocols
        --disable-protocols
        --enable-protocol=async
        --enable-protocol=cache
        --enable-protocol=crypto
        --enable-protocol=data
        --enable-protocol=file
        --enable-protocol=ftp
        --enable-protocol=hls
        --enable-protocol=pipe
        --enable-protocol=http,https,httpproxy
        # --enable-protocol=android_content
        --enable-protocol=subfile
        --enable-protocol=tcp,udp,tls

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
        --disable-libmysofa
        --disable-libplacebo
        --disable-libshaderc
        --disable-libfontconfig

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
        --enable-libvpl
        --enable-libjxl
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
