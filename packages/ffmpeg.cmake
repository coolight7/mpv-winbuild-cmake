ExternalProject_Add(ffmpeg
    DEPENDS
        angle-headers
        amf-headers
        avisynth-headers
        nvcodec-headers
        bzip2
        # lame # mp3 encoder
        lcms2
        openssl
        # libssh
        # libsrt
        # libass
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
        # libmysofa
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
        # libjxl
        libplacebo
        # libzvbi       # 用于解析电视信号帧之间空白间隔内的信息
        # libaribcaption # 解析、转换日本 ARIB STD-B24 标准字幕格式
        # aom         # av1 编解码，主要编码
        # svtav1      # av1 编解码
        dav1d
        # vapoursynth  # python 扩展视频处理
        ${ffmpeg_uavs3d}
        # ${ffmpeg_davs2}
        rubberband
        libva
        # openal-soft # ffmpeg 与 mpv 都已 disable openal，没有任何包链接它
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
    GIT_TAG n9.0.1
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
        --extra-cflags='${CFLAGS} -Wno-error=int-conversion -ffunction-sections -fdata-sections'
        --extra-cxxflags='${CXXFLAGS} -ffunction-sections -fdata-sections'
        --extra-ldflags='${LDFLAGS} '
        --extra-libs='${ffmpeg_extra_libs} -lm'

        --disable-gpl
        --disable-nonfree
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
        --enable-small
        --enable-optimizations

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
        
        # program
        --disable-programs

        --enable-avutil
        --enable-avcodec
        --enable-avfilter
        --enable-avformat
        --enable-avdevice
        --enable-swscale
        --enable-swresample

        --enable-hwaccels

        --disable-indevs
        --disable-outdevs
        --enable-indev=lavfi

        --disable-bsfs
	    --enable-bsf=aac_adtstoasc,chomp,dca_core,dovi_rpu,dovi_split,dts2pts,dump_extradata,dv_error_marker,eac3_core,evc_frame_merge,extract_extradata,filter_units,h264_mp4toannexb,h264_redundant_pps,hapqa_extract,hevc_mp4toannexb,imx_dump_header,mjpeg2jpeg,mjpega_dump_header,mpeg4_unpack_bframes,null,pcm_rechunk,remove_extradata,setts,showinfo,truehd_core

        --enable-parsers
        --disable-parser=cook,dvdsub,dvbsub,dvd_nav,g723_1,xma,sipr,bmp,adx
        
        --disable-decoders
        --enable-decoder=aac*,ac3*,acelp_*,alac,als,amrnb,amrwb,amv,ansi,anull,ape,apng,atrac*,av1,av1_*,avrn,avrp,avs,avui,bitpacked,cavs,cfhd,clearvideo,dca,dds,dfpwm,dirac,dnxhd,dolby_e,dpx,dsd_*,dss_sp,dst,dvaudio,dvvideo,dxtory,dxv,eac3,eacmv,eightbps,eightsvx_exp,eightsvx_fib,exr,fastaudio,ffv1,ffvhuff,ffwavesynth,fic,fits,flac,flashsv,flashsv2,flv,fmvc,fraps,frwu,ftr,g729,gdv,gif,h261,h263*,h264*,hap,hdr,hevc*,hq_hqa,hqx,huffyuv,hymt,iac,idf,iff_ilbm,imc,imm4,imm5,jpeg2000,jpegls,kgv1,kmvc,lagarith,lead,libdav1d,libopus,libuavs3d,libvorbis,libvpx*,loco,lscr,mace3,mace6,magicyuv,media100,metasound,misc4,mjpeg*,mlp,mmvideo,mobiclip,mp1*,mp2*,mp3*,mpc*,mpeg*,mpl2,msa1,mscc,msmpeg*,msnsiren,msp2,msrle,mss*,msvideo1,mszh,mts2,mv30,mvc1,mvc2,mvdv,mvha,mwsc,mxpeg,notchlc,nuv,on2avc,opus,osq,paf_audio,paf_video,pam,pbm,pcm_*,pcx,pdv,pfm,pgm,pgmyuv,pgx,phm,photocd,pictor,pixlet,pjs,png,ppm,prores,prores_raw,prosumer,ptx,qdraw,qoa,qoi,qpeg,qtrle,r10k,r210,ra_144,ra_288,ralf,rasc,rawvideo,rka,rpza,rscc,rtv1,rv*,s302m,sbc,sga,sgi,sgirle,sheervideo,simbiosis_imx,siren,smackaud,smc,smvjpeg,snow,sp5x,speedhq,speex,srgc,sunrast,svq1,svq3,tak,targa,targa_y216,tdsc,text,theora,tiff,truehd,tscc,tscc2,tta,twinvq,ulti,utvideo,vb,vble,vbn,vc1*,vmix,vnull,vorbis,vp*,vqc,vvc*,wavarc,wavpack,wbmp,wcmv,webp,webp_anim,wmalossless,wmapro,wmav*,wmv*,wnv1,wrapped_avframe,xbin,xbm,xface,xl,xpm,xwd,y41p,ylc,yop,yuv4,zero12v,zerocodec

        --disable-encoders
        --enable-encoder=mjpeg,mjpeg_*,anull,vnull

        --disable-muxers
        --enable-muxer=image2*,mjpeg,null

        --disable-demuxers
        --enable-demuxer=aa,aac,aax,ac3,ac4,aiff,alp,amr,amrnb,amrwb,apac,ape,apm,apng,apv,asf,asf_o,ast,au,av1,avi,avr,avs,avs2,avs3,bintext,bit,bitpacked,caf,cavsvideo,cdg,cine,concat,dash,data,daud,dfpwm,dirac,dnxhd,dsf,dss,dts,dtshd,dv,eac3,evc,ffmetadata,filmstrip,fits,flac,flic,flv,g722,g726,g726le,g729,gif,h261,h263,h264,hcom,hevc,hls,hnm,iamf,ico,idf,iff,ifv,image2*,image_*,iss,iv8,ivf,lc3,live_flv,loas,luodat,m4v,matroska,mjpeg,mjpeg_2000,mlp,mlv,mov,mp3,mpc,mpc8,mpegps,mpegts,mpegtsraw,mpegvideo,mpjpeg,mtv,mv,mvi,mxf,mxg,nc,nistsphere,nsp,nsv,nut,obu,ogg,oma,osq,paf,pcm_*,pdv,pjs,pmp,pva,pvf,qoa,r3d,rawvideo,rcwt,rka,rm,rsd,rso,s337m,sap,sbc,scd,sdp,sdr2,sdx,sga,siff,simbiosis_imx,sln,smjpeg,sox,spdif,sup,swf,tak,truehd,tta,ty,vc1,vc1t,vividas,vivo,voc,vqf,vvc,w64,wady,wav,wavarc,webm_dash_manifest,webp_anim,wsd,wsvqa,wtv,wv,wve,xa,xbin,xmd,xmv,xwma,yop,yuv4mpegpipe

        --disable-filters
        --enable-filter=format
        --enable-filter=aformat
        --enable-filter=noformat
        --enable-filter=hwdownload
        --enable-filter=hwupload
        --enable-filter=copy
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
        --enable-filter=volume
        --enable-filter=volumedetect
        --enable-filter=null,nullsink,nullsrc,anull,anullsink,anullsrc
        --enable-filter=amix
        --enable-filter=aselect
        --enable-filter=atempo
        --enable-filter=aresample
        --enable-filter=sinc
        --enable-filter=sine
        --enable-filter=vibrato,tremolo
        # D3D12 硬件滤镜（依赖 --enable-d3d12va，需 mingw-w64 头文件提供 ID3D12VideoProcessor/ID3D12VideoMotionEstimator）
        --enable-filter=scale_d3d12,deinterlace_d3d12,mestimate_d3d12

        # protocols
        --disable-protocols
        # --enable-protocol=android_content
        --enable-protocol=async,cache,crypto,data,file,pipe,http,https,httpproxy,subfile,tcp,udp,tls

        --disable-libmfx
        --disable-avisynth
        --disable-vapoursynth
        --disable-whisper
        --disable-libbluray
        --disable-libdvdnav
        --disable-libdvdread
        --disable-libmodplug
        --disable-libopenmpt
        # jxl 图片解码：本项目的封面/图片均为 jpeg/png/gif/bmp/webp，不需要（同时省掉 libjxl 及其独占依赖 highway）
        --disable-libjxl
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
        --disable-libharfbuzz
        --disable-libass
        --disable-libfreetype
        --disable-libfribidi
        
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
	    --enable-iconv
        --enable-zlib
        --enable-bzlib
        --enable-lzma
        # ${ffmpeg_davs2_cmd}
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
