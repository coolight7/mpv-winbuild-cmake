ExternalProject_Add(ffmpeg
    DEPENDS
        angle-headers
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
        spirv-cross
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
        --disable-shared
        --enable-static
        --enable-stripping
        --enable-runtime-cpudetect
        --enable-pic
        --enable-asm 
        --enable-inline-asm
        --enable-lto=full
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

        --enable-parsers
        
        --enable-decoders
        --disable-decoder=libaom_av1
	    --disable-decoder=srt,ass,ssa,realtext,libzvbi_teletext,movtext,bintext,dvbsub,dvdsub,subrip,jacosub,subviewer,subviewer1,pgssub,xsub,ccaption,libaribb24,libaribcaption,microdvd,sami,stl,webvtt
	    --disable-decoder=libgme,libmodplug,libopenmpt
	    --disable-decoder=indeo2,indeo3,indeo4,indeo5,cinepak
	    --disable-decoder=bethsoftvid,idcin,roq_*,smacker,xan_*,c93,vcr1,vcr2,vqa,bink,binkaudio_dct,binkaudio_rdft,thp,dfa,ipu
	    --disable-decoder=truespeech,tiertexseqvideo,nellymoser,qdmc,qdmc_at,qdm2,qdm2_at,g723_1,g728,sipr,ws_snd1,tmv,bonk,shorten,sol_dpcm
        
        --disable-decoder=zlib,zmbv,aasc,alias_pix,agm,anm,apv,arbc,argo,bmv_video,brender_pix,cdgraphics,cdtoons,cri,cdxl,cllc,cpia,camstudio,dxa,flic,4xm,gem,hnm4video,interplayvideo,mdec,mimic,psd,rasc.rl2,roqvideo,txd,vmnc,asv1,asv2,aura,aura2
        --disable-decoder=8svx_exp,8svx_fib,hca,hcom,interplayacm,xma1,xma2,cook

        --disable-encoders
        --enable-encoder=mjpeg*
        --enable-encoder=ljpeg
        --enable-encoder=jpegls
        --enable-encoder=jpeg2000
        --enable-encoder=anull,vnull

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
        --enable-filter=areverse,reverse
        --enable-filter=silencedetect,silenceremove
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
        --disable-libfontconfig

	    --disable-vulkan
        --disable-vulkan-static
        --disable-libshaderc
        --disable-libplacebo
        
        --enable-network
        --enable-amf
        --enable-d3d12va
        --enable-d3d11va
        --enable-vaapi
        --disable-dxva2
        --disable-openal
        --disable-opengl
        ${ffmpeg_cuda}
        --enable-libuavs3d
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
        --enable-libvpl
        --enable-libjxl
	    --enable-iconv
        --enable-zlib
        --enable-bzlib
        --enable-lzma
        ${ffmpeg_davs2_cmd}
        ${ffmpeg_uavs3d_cmd}
        --extra-cflags='-Wno-error=int-conversion -fPIC'
        "--extra-libs='${ffmpeg_extra_libs} -lm'"
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
