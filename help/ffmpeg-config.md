# FFmpeg n9.0.1 构建配置与组件全景清单

> 本文档以 **FFmpeg `n8.0.2`** 的源码与 **`mpv-winbuild-cmake/packages/ffmpeg.cmake`** 构建配置为起点整理，并已对比更新到 **FFmpeg `n9.0.1`**（依据 n8.0.2 → n9.0.1 的增删比对结果合并整理）。
> 下文各模块清单均以 **n9.0.1 当前状态与最新 `ffmpeg.cmake` 配置**为准，不再逐条标注版本信息；n8.0.2 → n9.0.1 的增删总量见第 0 节，已被 n9.0.1 移除的条目集中记录在各模块的"已过时的禁用"列表中。
>
> 全文分为两大核心组成部分：
> 1. **第一部分：多媒体组件清单**：系统梳理 10 大核心组件模块（输入设备、输出设备、比特流滤镜、解析器、解码器、编码器、复用器、解复用器、滤镜、传输协议）共 **2220** 个多媒体组件的配置状态。
> 2. **第二部分：全局构建参数清单**：系统梳理除动态组件选择参数之外的全部 configure 参数，涵盖授权协议、库构建模式、程序、文档、核心库与子系统、外部第三方库、硬件加速、架构优化、开发调试选项以及交叉编译工具链参数。

---

## 0 版本说明与合并总览 (n8.0.2 → n9.0.1)

- **起点版本**：FFmpeg `n8.0.2`；**当前版本**：FFmpeg `n9.0.1`（`ffmpeg.cmake` 中 `GIT_TAG n9.0.1`）。
- **组件层**：10 大模块支持总数 `2195` → `2220`（**新增 42** 个、**移除 17** 个，净增 25 个）。
- **参数层**：configure 全局参数（不含动态组件选择项）**新增 20** 项、**移除 9** 项；另有 1 项参数默认值/帮助文本变化（`--extra-objcflags`）。
- **配置清理与新增（本次执行）**：
    - 清理已失效条目 3 个：`--enable-decoder=sonic`、`--enable-protocol=hls`、`--enable-demuxer=afx`（其中 `afx` 上游从未提供，属历史笔误），相关组件归入"已过时的禁用"。
    - 新增配置 4 组：动态 WebP 原生播放（`--enable-decoder=webp_anim` + `--enable-demuxer=webp_anim`）、Dolby Vision 双层拆分（`--enable-bsf=dovi_split`）、D3D12 硬件缩放/反交错/运动估计（`--enable-filter=scale_d3d12,deinterlace_d3d12,mestimate_d3d12`）。
    - `--enable-filter=drawvg` 因必须依赖 cairo（会引入新的外部库）未启用，`drawvg` 保留在禁用列表。
- **合并口径**：每个模块的配置列表统一拆分为四类，本章之后不再重复说明版本差异：

| 分类 | 含义 | 判定依据 |
| :--- | :--- | :--- |
| **启用 (Enabled)** | 当前配置下启用 | 白名单命中（`--enable-<类型>=...`）或黑名单未排除（解析器：`--enable-parsers` + `--disable-parser=...`） |
| **禁用 (Disabled)** | 当前配置下禁用（含评估后仍未启用的新增组件） | 白名单未命中、黑名单命中或 FFmpeg 默认关闭 |
| **已过时的启用 (Obsolete Enabled)** | 曾启用、现已失效的条目 —— 相关失效条目已从配置中清理，当前为空 | 配置清理结果 |
| **已过时的禁用 (Obsolete Disabled)** | **n9.0.1 已移除**的组件与参数（配置中已清理或原本未使用），仅作历史记录 | 上游 tag 对比结果 |

> **统计口径说明**：列表反映 **configure 选项的模式匹配结果（配置意图）**。带外部库/平台依赖的条目（如 `*_mediacodec`、`*_v4l2m2m`、`lgpl_gpl` 门控项、`shared` 协议等）在 configure 的依赖检查阶段可能被自动剔除，各模块说明中已逐项标注。

### 0.1 各模块增变统计

| 序号 | 组件模块 | 组件分类 | n8.0.2 总数 | n9.0.1 总数 | 新增 | 移除 | 净增 |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | `indevs` | 输入设备 | 20 | 20 | +0 | -0 | 0 |
| 2 | `outdevs` | 输出设备 | 10 | 10 | +0 | -0 | 0 |
| 3 | `bsf` | 比特流滤镜 | 48 | 51 | +3 | -0 | +3 |
| 4 | `parser` | 解析器 | 64 | 68 | +4 | -0 | +4 |
| 5 | `decoders` | 解码器 | 596 | 603 | +12 | -5 | +7 |
| 6 | `encoders` | 编码器 | 269 | 269 | +7 | -7 | 0 |
| 7 | `muxers` | 复用器 | 184 | 185 | +1 | -0 | +1 |
| 8 | `demuxers` | 解复用器 | 364 | 367 | +3 | -0 | +3 |
| 9 | `filters` | 滤镜 | 585 | 592 | +11 | -4 | +7 |
| 10 | `protocols` | 传输协议 | 55 | 55 | +1 | -1 | 0 |
| **合计** | - | - | **2195** | **2220** | **+42** | **-17** | **+25** |

### 0.2 全局参数增变统计

| 参数分类模块 | 模块英文标识 | 新增 | 移除 |
| :--- | :--- | :---: | :---: |
| 库构建模式与通用配置 | Configuration Options | `--disable-checkasm`、`--disable-unstable` | - |
| 外部第三方库支持 | External Library Support | `--enable-cairo`、`--enable-libmpeghdec`、`--enable-libonnxruntime`、`--enable-libopencolorio`、`--enable-libsvtjpegxs`、`--enable-libxevdb`、`--enable-libxeveb` | `--enable-libcelt`、`--enable-libglslang`、`--enable-libnpp`、`--enable-libshaderc` |
| 硬件加速功能 | Hardware Acceleration Features | - | `--enable-omx`、`--enable-omx-rpi` |
| 架构与指令集优化选项 | Optimization Options | `--disable-arm-crc`、`--disable-clmul`、`--disable-eor3`、`--disable-pmull`、`--disable-sme`、`--disable-sme-i16i64`、`--disable-sme2` | `--disable-amd3dnow`、`--disable-amd3dnowext` |
| 开发与调试测试选项 | Developer & Debugging Options | `--disable-shader-compression` | `--disable-ptx-compression`（被前者取代） |
| 构建工具链与编译选项 | Toolchain Options | `--glslc=GLSLC`、`--glslcflags=GLSLCFLAGS`、`--makeinfo=MAKEINFO` | - |

---

# 第一部分：多媒体组件配置清单 (10 大类别)

## 1.1 组件总体统计汇总

| 序号 | 组件模块 (英文) | 组件分类 (中文) | 支持总数 | 启用 (Enabled) | 已过时的启用 | 禁用 (Disabled) | 已过时的禁用 | 启用率 | 配置策略 |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| 1 | `indevs` | 输入设备 | **20** | **1** | **0** | **19** | **0** | 5.0% | 白名单（仅保留 lavfi 虚拟源） |
| 2 | `outdevs` | 输出设备 | **10** | **0** | **0** | **10** | **0** | 0.0% | 全量禁用（由 mpv 自主渲染） |
| 3 | `bsf` | 比特流滤镜 | **51** | **26** | **0** | **25** | **0** | 51.0% | 白名单（保留流封装转换与核心元数据） |
| 4 | `parser` | 解析器 | **68** | **59** | **0** | **9** | **0** | 86.8% | 黑名单（默认全开，排除 9 个罕见解析器） |
| 5 | `decoders` | 解码器 | **603** | **411** | **0** | **192** | **5** | 68.2% | 白名单（主流格式与高性能硬解软解） |
| 6 | `encoders` | 编码器 | **269** | **5** | **0** | **264** | **7** | 1.9% | 白名单（仅截屏与空占位编码器） |
| 7 | `muxers` | 复用器 | **185** | **4** | **0** | **181** | **0** | 2.2% | 白名单（仅单帧图片与空复用器） |
| 8 | `demuxers` | 解复用器 | **367** | **244** | **0** | **123** | **0** | 66.5% | 白名单（全覆盖主流格式容器） |
| 9 | `filters` | 滤镜 | **592** | **46** | **0** | **546** | **4** | 7.8% | 白名单（仅保留音频与核心格式转换） |
| 10 | `protocols` | 传输协议 | **55** | **13** | **0** | **42** | **1** | 23.6% | 白名单（仅保留常用网络与文件协议） |
| **合计** | - | - | **2220** | **809** | **0** | **1411** | **17** | **36.4%** | - |

> 交叉校验：`启用 + 禁用 = 809 + 1411 = 2220`（= 支持总数）；`已过时的禁用 = 17`（= 累计被移除的组件数）。

---

## 1.2 输入设备 (Input Devices / indevs)

输入设备负责从系统硬件、外设或虚拟源（如 DirectShow、v4l2、音频采集设备、lavfi 虚拟滤镜源等）捕获多媒体数据流。

- **总支持数**：`20` 个
- **启用数量**：`1` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`19` 个 ｜ **已过时的禁用数量**：`0` 个

### 配置规则

```cmake
--disable-indevs
--enable-indev=lavfi
```

### 配置解析与说明

当前配置禁用了所有物理硬件和底层系统采集设备，仅启用了 `lavfi`（用于在 libavdevice 中接入 libavfilter 滤镜图生成虚拟音视频源，mpv 渲染管线可能需要）。

### 启用列表 (Enabled - 共 1 项)

- `lavfi`

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 19 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `alsa` | `android_camera` | `avfoundation` | `decklink` |
| `dshow` | `fbdev` | `gdigrab` | `iec61883` |
| `jack` | `kmsgrab` | `libcdio` | `libdc1394` |
| `openal` | `oss` | `pulse` | `sndio` |
| `v4l2` | `vfwcap` | `xcbgrab` |  |

### 已过时的禁用列表 (Obsolete Disabled - 共 0 项)

*（无）*

---

## 1.3 输出设备 (Output Devices / outdevs)

输出设备负责将音视频流直接渲染输出到系统硬件或底层视音频接口（如 ALSA、PulseAudio、SDL、OpenGL 视窗等）。

- **总支持数**：`10` 个
- **启用数量**：`0` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`10` 个 ｜ **已过时的禁用数量**：`0` 个

### 配置规则

```cmake
--disable-outdevs
```

### 配置解析与说明

当前配置禁用了所有 FFmpeg 内置输出设备。mpv 播放器拥有自主的音视频渲染管线（基于 libplacebo、Direct3D、Vulkan、OpenGL 及 WASAPI/AudioGraph 等），不依赖 FFmpeg 的输出设备。

### 启用列表 (Enabled - 共 0 项)

*（无）*

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 10 项)

- `alsa`
- `audiotoolbox`
- `caca`
- `decklink`
- `fbdev`
- `oss`
- `pulse`
- `sndio`
- `v4l2`
- `xv`

### 已过时的禁用列表 (Obsolete Disabled - 共 0 项)

*（无）*

---

## 1.4 比特流滤镜 (Bitstream Filters / bsf)

比特流滤镜在不需要重新解码和编码的情况下，对编码码流的封装头部、元数据、参数集（SPS/PPS/VPS）、时间戳等结构进行二进制级别的修改与修复。

- **总支持数**：`51` 个
- **启用数量**：`26` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`25` 个 ｜ **已过时的禁用数量**：`0` 个

### 配置规则

```cmake
--disable-bsfs
--enable-bsf=aac_adtstoasc,chomp,dca_core,dovi_rpu,dovi_split,dts2pts,dump_extradata,dv_error_marker,eac3_core,evc_frame_merge,extract_extradata,filter_units,h264_mp4toannexb,h264_redundant_pps,hapqa_extract,hevc_mp4toannexb,imx_dump_header,mjpeg2jpeg,mjpega_dump_header,mpeg4_unpack_bframes,null,pcm_rechunk,remove_extradata,setts,showinfo,truehd_core
```

### 配置解析与说明

采用白名单机制，精简保留了常见的封装转换滤镜（如 `h264_mp4toannexb`、`hevc_mp4toannexb`、`aac_adtstoasc`）、Dolby Vision 杜比视界 RPU 提取 (`dovi_rpu`)、核心音频提取 (`dca_core`、`eac3_core`、`truehd_core`) 等关键滤镜。

- `dovi_split` 已按需启用（Dolby Vision 单轨双层/混合流拆分为 RPU 元数据层与基础视频层）；`ahx_to_mp2` 带 `lgpl_gpl` 依赖（仅 `--enable-gpl` 时构建），本构建为 `--disable-gpl`，即使加入白名单也不会构建。

### 启用列表 (Enabled - 共 26 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `aac_adtstoasc` | `chomp` | `dca_core` | `dovi_rpu` |
| `dovi_split` | `dts2pts` | `dump_extradata` | `dv_error_marker` |
| `eac3_core` | `evc_frame_merge` | `extract_extradata` | `filter_units` |
| `h264_mp4toannexb` | `h264_redundant_pps` | `hapqa_extract` | `hevc_mp4toannexb` |
| `imx_dump_header` | `mjpeg2jpeg` | `mjpega_dump_header` | `mpeg4_unpack_bframes` |
| `null` | `pcm_rechunk` | `remove_extradata` | `setts` |
| `showinfo` | `truehd_core` |  |  |

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 25 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `ahx_to_mp2` | `apv_metadata` | `av1_frame_merge` | `av1_frame_split` |
| `av1_metadata` | `eia608_to_smpte436m` | `h264_metadata` | `hevc_metadata` |
| `lcevc_metadata` | `media100_to_mjpegb` | `mov2textsub` | `mpeg2_metadata` |
| `noise` | `opus_metadata` | `pgs_frame_merge` | `prores_metadata` |
| `smpte436m_to_eia608` | `text2movsub` | `trace_headers` | `vp9_metadata` |
| `vp9_raw_reorder` | `vp9_superframe` | `vp9_superframe_split` | `vvc_metadata` |
| `vvc_mp4toannexb` |  |  |  |

### 已过时的禁用列表 (Obsolete Disabled - 共 0 项)

*（无）*

---

## 1.5 解析器 (Parsers / parser)

解析器负责将未分帧或无容器的原始编码数据流分割为具有完整逻辑结构的数据包（AVPacket），提取关键帧信息、显示时间戳以及元数据头。

- **总支持数**：`68` 个
- **启用数量**：`59` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`9` 个 ｜ **已过时的禁用数量**：`0` 个

### 配置规则

```cmake
--enable-parsers
--disable-parser=cook,dvdsub,dvbsub,dvd_nav,g723_1,xma,sipr,bmp,adx
```

### 配置解析与说明

采用黑名单机制：默认启用 FFmpeg 支持的所有解析器，仅排除了 9 个老旧、罕见或不需要的专用解析器（如 RealAudio cook、DVD/DVB 字幕、G.723.1、XMA、BMP 等）。

- `ahx` 解析器带 `lgpl_gpl` 依赖（仅 `--enable-gpl` 时构建），本构建为 `--disable-gpl`，实际 configure 结果中会被剔除；此处按"配置意图"仍计入启用列表，与 `*_mediacodec`、`*_v4l2m2m` 等依赖剔除项的处理口径一致。
- `jpegxs`、`lcevc` 解析器本身不提供解码能力：JPEG XS 需引入外部库（`--enable-libsvtjpegxs`）才有软解，LCEVC 增强层解码在本构建中未启用任何实现，因此它们不改变实际可播放格式集合。

### 启用列表 (Enabled - 共 59 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `aac` | `aac_latm` | `ac3` | `ahx` |
| `amr` | `apv` | `av1` | `avs2` |
| `avs3` | `cavsvideo` | `cri` | `dca` |
| `dirac` | `dnxhd` | `dnxuc` | `dolby_e` |
| `dpx` | `dvaudio` | `evc` | `ffv1` |
| `flac` | `ftr` | `g729` | `gif` |
| `gsm` | `h261` | `h263` | `h264` |
| `hdr` | `hevc` | `ipu` | `jpeg2000` |
| `jpegxl` | `jpegxs` | `lcevc` | `misc4` |
| `mjpeg` | `mlp` | `mpeg4video` | `mpegaudio` |
| `mpegvideo` | `opus` | `png` | `pnm` |
| `prores` | `prores_raw` | `qoi` | `rv34` |
| `sbc` | `tak` | `vc1` | `vorbis` |
| `vp3` | `vp8` | `vp9` | `vvc` |
| `webp` | `xbm` | `xwd` |  |

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 9 项)

- `adx`
- `bmp`
- `cook`
- `dvbsub`
- `dvd_nav`
- `dvdsub`
- `g723_1`
- `sipr`
- `xma`

### 已过时的禁用列表 (Obsolete Disabled - 共 0 项)

*（无）*

---

## 1.6 解码器 (Decoders / decoders)

解码器负责将压缩的音视频、字幕及附属数据解码为原始帧（如 YUV/RGB 像素数据、PCM 音频样本）。

- **总支持数**：`603` 个
- **启用数量**：`411` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`192` 个 ｜ **已过时的禁用数量**：`5` 个

### 配置规则

```cmake
--disable-decoders
--enable-decoder=aac*,ac3*,acelp_*,alac,als,amrnb,amrwb,amv,ansi,anull,ape,apng,atrac*,av1,av1_*,avrn,avrp,avs,avui,bitpacked,bmv_audio,cavs,cbd2_dpcm,cfhd,clearvideo,cljr,cyuv,dca,dds,derf_dpcm,dfpwm,dirac,dnxhd,dolby_e,dpx,dsd_*,dsicinaudio,dsicinvideo,dss_sp,dst,dvaudio,dvvideo,dxtory,dxv,eac3,eacmv,eamad,eatgq,eatgv,eatqi,eightbps,eightsvx_exp,eightsvx_fib,escape124,escape130,evrc,exr,fastaudio,ffv1,ffvhuff,ffwavesynth,fic,fits,flac,flashsv,flashsv2,flv,fmvc,fraps,frwu,ftr,g2m,g729,gdv,gif,gremlin_dpcm,h261,h263*,h264*,hap,hdr,hevc*,hnm4_video,hq_hqa,hqx,huffyuv,hymt,iac,idf,iff_ilbm,ilbc,imc,imm4,imm5,interplay_acm,interplay_dpcm,interplay_video,jpeg2000,jpegls,jv,kgv1,kmvc,lagarith,lead,libdav1d,libjxl*,libopus,libuavs3d,libvorbis,libvpx*,loco,lscr,m101,mace3,mace6,magicyuv,media100,metasound,misc4,mjpeg*,mlp,mmvideo,mobiclip,motionpixels,mp1*,mp2*,mp3*,mpc*,mpeg*,mpl2,msa1,mscc,msmpeg*,msnsiren,msp2,msrle,mss*,msvideo1,mszh,mts2,mv30,mvc1,mvc2,mvdv,mvha,mwsc,mxpeg,notchlc,nuv,on2avc,opus,osq,paf_audio,paf_video,pam,pbm,pcm_*,pcx,pdv,pfm,pgm,pgmyuv,pgx,phm,photocd,pictor,pixlet,pjs,png,ppm,prores,prores_raw,prosumer,ptx,qcelp,qdraw,qoa,qoi,qpeg,qtrle,r10k,r210,ra_144,ra_288,ralf,rasc,rawvideo,rka,rl2,roq,rpza,rscc,rtv1,rv*,s302m,sanm,sbc,scpr,screenpresso,sdx2_dpcm,sga,sgi,sgirle,sheervideo,simbiosis_imx,siren,smackaud,smc,smvjpeg,snow,sp5x,speedhq,speex,srgc,sunrast,svq1,svq3,tak,targa,targa_y216,tdsc,text,theora,tiff,truehd,truemotion1,truemotion2,truemotion2rt,tscc,tscc2,tta,twinvq,ulti,utvideo,vb,vble,vbn,vc1*,vmdaudio,vmdvideo,vmix,vnull,vorbis,vp*,vqc,vvc*,wady_dpcm,wavarc,wavpack,wbmp,wcmv,webp,webp_anim,wmalossless,wmapro,wmav*,wmv*,wnv1,wrapped_avframe,xbin,xbm,xface,xl,xpm,xwd,y41p,ylc,yop,yuv4,zero12v,zerocodec
```

### 配置解析与说明

1. **全面覆盖主流与历史格式**：涵盖 H.264、HEVC、AV1、VVC、VP8/VP9、MPEG-1/2/4、ProRes、VC-1、AAC、AC3、EAC3、TrueHD、DTS、FLAC、Opus、Vorbis 等各类音视频及字幕解码格式。
2. **通配符展开与硬件加速匹配**：通配符如 `h264*`、`hevc*`、`av1_*` 匹配了原生软解及部分硬件加速接口（如 `_cuvid`、`_amf`）。其中结合配置中的 `--enable-cuvid`、`--enable-amf` 生效；而其他平台专属实现（如 `mediacodec`、`audiotoolbox`、`v4l2m2m`）因其底层平台库未启用，将在 configure 依赖检查阶段自动被剔除。
3. **外部库解码器**：启用了外部优秀解码库支持，包括 `libdav1d` (AV1)、`libuavs3d` (AVS3)、`libjxl` (JPEG XL)、`libopus`、`libvorbis`、`libvpx` (VP8/VP9)。

- `webp_anim` 解码器与同名解复用器已一并启用，构成动态 WebP 的原生播放链路；`adpcm_*`（8 个）与 `ahx` 解码器带 `lgpl_gpl` 依赖（仅 `--enable-gpl` 时构建），本构建为 `--disable-gpl`，即便加入白名单也不会构建；`libmpeghdec`、`libsvtjpegxs` 需先引入对应外部库。

### 启用列表 (Enabled - 共 411 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `aac` | `aac_at` | `aac_fixed` | `aac_latm` |
| `aac_mediacodec` | `ac3` | `ac3_at` | `ac3_fixed` |
| `acelp_kelvin` | `alac` | `als` | `amrnb` |
| `amrwb` | `amv` | `ansi` | `anull` |
| `ape` | `apng` | `atrac1` | `atrac3` |
| `atrac3al` | `atrac3p` | `atrac3pal` | `atrac9` |
| `av1` | `av1_amf` | `av1_cuvid` | `av1_mediacodec` |
| `av1_qsv` | `avrn` | `avrp` | `avs` |
| `avui` | `bitpacked` | `bmv_audio` | `cavs` |
| `cbd2_dpcm` | `cfhd` | `clearvideo` | `cljr` |
| `cyuv` | `dca` | `dds` | `derf_dpcm` |
| `dfpwm` | `dirac` | `dnxhd` | `dolby_e` |
| `dpx` | `dsd_lsbf` | `dsd_lsbf_planar` | `dsd_msbf` |
| `dsd_msbf_planar` | `dsicinaudio` | `dsicinvideo` | `dss_sp` |
| `dst` | `dvaudio` | `dvvideo` | `dxtory` |
| `dxv` | `eac3` | `eacmv` | `eamad` |
| `eatgq` | `eatgv` | `eatqi` | `eightbps` |
| `eightsvx_exp` | `eightsvx_fib` | `escape124` | `escape130` |
| `evrc` | `exr` | `fastaudio` | `ffv1` |
| `ffvhuff` | `ffwavesynth` | `fic` | `fits` |
| `flac` | `flashsv` | `flashsv2` | `flv` |
| `fmvc` | `fraps` | `frwu` | `ftr` |
| `g2m` | `g729` | `gdv` | `gif` |
| `gremlin_dpcm` | `h261` | `h263` | `h263_v4l2m2m` |
| `h263i` | `h263p` | `h264` | `h264_amf` |
| `h264_cuvid` | `h264_mediacodec` | `h264_mmal` | `h264_oh` |
| `h264_qsv` | `h264_rkmpp` | `h264_v4l2m2m` | `hap` |
| `hdr` | `hevc` | `hevc_amf` | `hevc_cuvid` |
| `hevc_mediacodec` | `hevc_oh` | `hevc_qsv` | `hevc_rkmpp` |
| `hevc_v4l2m2m` | `hnm4_video` | `hq_hqa` | `hqx` |
| `huffyuv` | `hymt` | `iac` | `idf` |
| `iff_ilbm` | `ilbc` | `imc` | `imm4` |
| `imm5` | `interplay_acm` | `interplay_dpcm` | `interplay_video` |
| `jpeg2000` | `jpegls` | `jv` | `kgv1` |
| `kmvc` | `lagarith` | `lead` | `libdav1d` |
| `libjxl` | `libjxl_anim` | `libopus` | `libuavs3d` |
| `libvorbis` | `libvpx_vp8` | `libvpx_vp9` | `loco` |
| `lscr` | `m101` | `mace3` | `mace6` |
| `magicyuv` | `media100` | `metasound` | `misc4` |
| `mjpeg` | `mjpeg_cuvid` | `mjpeg_qsv` | `mjpegb` |
| `mlp` | `mmvideo` | `mobiclip` | `motionpixels` |
| `mp1` | `mp1_at` | `mp1float` | `mp2` |
| `mp2_at` | `mp2float` | `mp3` | `mp3_at` |
| `mp3_mediacodec` | `mp3adu` | `mp3adufloat` | `mp3float` |
| `mp3on4` | `mp3on4float` | `mpc7` | `mpc8` |
| `mpeg1_cuvid` | `mpeg1_v4l2m2m` | `mpeg1video` | `mpeg2_cuvid` |
| `mpeg2_mediacodec` | `mpeg2_mmal` | `mpeg2_qsv` | `mpeg2_v4l2m2m` |
| `mpeg2video` | `mpeg4` | `mpeg4_cuvid` | `mpeg4_mediacodec` |
| `mpeg4_mmal` | `mpeg4_v4l2m2m` | `mpegvideo` | `mpl2` |
| `msa1` | `mscc` | `msmpeg4v1` | `msmpeg4v2` |
| `msmpeg4v3` | `msnsiren` | `msp2` | `msrle` |
| `mss1` | `mss2` | `msvideo1` | `mszh` |
| `mts2` | `mv30` | `mvc1` | `mvc2` |
| `mvdv` | `mvha` | `mwsc` | `mxpeg` |
| `notchlc` | `nuv` | `on2avc` | `opus` |
| `osq` | `paf_audio` | `paf_video` | `pam` |
| `pbm` | `pcm_alaw` | `pcm_alaw_at` | `pcm_bluray` |
| `pcm_dvd` | `pcm_f16le` | `pcm_f24le` | `pcm_f32be` |
| `pcm_f32le` | `pcm_f64be` | `pcm_f64le` | `pcm_lxf` |
| `pcm_mulaw` | `pcm_mulaw_at` | `pcm_s16be` | `pcm_s16be_planar` |
| `pcm_s16le` | `pcm_s16le_planar` | `pcm_s24be` | `pcm_s24daud` |
| `pcm_s24le` | `pcm_s24le_planar` | `pcm_s32be` | `pcm_s32le` |
| `pcm_s32le_planar` | `pcm_s64be` | `pcm_s64le` | `pcm_s8` |
| `pcm_s8_planar` | `pcm_sga` | `pcm_u16be` | `pcm_u16le` |
| `pcm_u24be` | `pcm_u24le` | `pcm_u32be` | `pcm_u32le` |
| `pcm_u8` | `pcm_vidc` | `pcx` | `pdv` |
| `pfm` | `pgm` | `pgmyuv` | `pgx` |
| `phm` | `photocd` | `pictor` | `pixlet` |
| `pjs` | `png` | `ppm` | `prores` |
| `prores_raw` | `prosumer` | `ptx` | `qcelp` |
| `qdraw` | `qoa` | `qoi` | `qpeg` |
| `qtrle` | `r10k` | `r210` | `ra_144` |
| `ra_288` | `ralf` | `rasc` | `rawvideo` |
| `rka` | `rl2` | `roq` | `rpza` |
| `rscc` | `rtv1` | `rv10` | `rv20` |
| `rv30` | `rv40` | `rv60` | `s302m` |
| `sanm` | `sbc` | `scpr` | `screenpresso` |
| `sdx2_dpcm` | `sga` | `sgi` | `sgirle` |
| `sheervideo` | `simbiosis_imx` | `siren` | `smackaud` |
| `smc` | `smvjpeg` | `snow` | `sp5x` |
| `speedhq` | `speex` | `srgc` | `sunrast` |
| `svq1` | `svq3` | `tak` | `targa` |
| `targa_y216` | `tdsc` | `text` | `theora` |
| `tiff` | `truehd` | `truemotion1` | `truemotion2` |
| `truemotion2rt` | `tscc` | `tscc2` | `tta` |
| `twinvq` | `ulti` | `utvideo` | `vb` |
| `vble` | `vbn` | `vc1` | `vc1_cuvid` |
| `vc1_mmal` | `vc1_qsv` | `vc1_v4l2m2m` | `vc1image` |
| `vmdaudio` | `vmdvideo` | `vmix` | `vnull` |
| `vorbis` | `vp3` | `vp4` | `vp5` |
| `vp6` | `vp6a` | `vp6f` | `vp7` |
| `vp8` | `vp8_cuvid` | `vp8_mediacodec` | `vp8_qsv` |
| `vp8_rkmpp` | `vp8_v4l2m2m` | `vp9` | `vp9_amf` |
| `vp9_cuvid` | `vp9_mediacodec` | `vp9_qsv` | `vp9_rkmpp` |
| `vp9_v4l2m2m` | `vplayer` | `vqc` | `vvc` |
| `vvc_qsv` | `wady_dpcm` | `wavarc` | `wavpack` |
| `wbmp` | `wcmv` | `webp` | `webp_anim` |
| `wmalossless` | `wmapro` | `wmav1` | `wmav2` |
| `wmavoice` | `wmv1` | `wmv2` | `wmv3` |
| `wmv3image` | `wnv1` | `wrapped_avframe` | `xbin` |
| `xbm` | `xface` | `xl` | `xpm` |
| `xwd` | `y41p` | `ylc` | `yop` |
| `yuv4` | `zero12v` | `zerocodec` |  |

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无 —— 原失效条目 `sonic` 已随配置清理，归入下方"已过时的禁用"）*

### 禁用列表 (Disabled - 共 192 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `aasc` | `adpcm_4xm` | `adpcm_adx` | `adpcm_afc` |
| `adpcm_agm` | `adpcm_aica` | `adpcm_argo` | `adpcm_circus` |
| `adpcm_ct` | `adpcm_dtk` | `adpcm_ea` | `adpcm_ea_maxis_xa` |
| `adpcm_ea_r1` | `adpcm_ea_r2` | `adpcm_ea_r3` | `adpcm_ea_xas` |
| `adpcm_g722` | `adpcm_g726` | `adpcm_g726le` | `adpcm_ima_acorn` |
| `adpcm_ima_alp` | `adpcm_ima_amv` | `adpcm_ima_apc` | `adpcm_ima_apm` |
| `adpcm_ima_cunning` | `adpcm_ima_dat4` | `adpcm_ima_dk3` | `adpcm_ima_dk4` |
| `adpcm_ima_ea_eacs` | `adpcm_ima_ea_sead` | `adpcm_ima_escape` | `adpcm_ima_hvqm2` |
| `adpcm_ima_hvqm4` | `adpcm_ima_iss` | `adpcm_ima_magix` | `adpcm_ima_moflex` |
| `adpcm_ima_mtf` | `adpcm_ima_oki` | `adpcm_ima_pda` | `adpcm_ima_qt` |
| `adpcm_ima_qt_at` | `adpcm_ima_rad` | `adpcm_ima_smjpeg` | `adpcm_ima_ssi` |
| `adpcm_ima_wav` | `adpcm_ima_ws` | `adpcm_ima_xbox` | `adpcm_ms` |
| `adpcm_mtaf` | `adpcm_n64` | `adpcm_psx` | `adpcm_psxc` |
| `adpcm_sanyo` | `adpcm_sbpro_2` | `adpcm_sbpro_3` | `adpcm_sbpro_4` |
| `adpcm_swf` | `adpcm_thp` | `adpcm_thp_le` | `adpcm_vima` |
| `adpcm_xa` | `adpcm_xmd` | `adpcm_yamaha` | `adpcm_zork` |
| `agm` | `ahx` | `aic` | `alac_at` |
| `alias_pix` | `amr_nb_at` | `amrnb_mediacodec` | `amrwb_mediacodec` |
| `anm` | `apac` | `aptx` | `aptx_hd` |
| `apv` | `arbc` | `argo` | `ass` |
| `asv1` | `asv2` | `aura` | `aura2` |
| `bethsoftvid` | `bfi` | `bink` | `binkaudio_dct` |
| `binkaudio_rdft` | `bintext` | `bmp` | `bmv_video` |
| `bonk` | `brender_pix` | `c93` | `ccaption` |
| `cdgraphics` | `cdtoons` | `cdxl` | `cinepak` |
| `cllc` | `comfortnoise` | `cook` | `cpia` |
| `cri` | `cscd` | `dfa` | `dvbsub` |
| `dvdsub` | `dxa` | `eac3_at` | `flic` |
| `fourxm` | `g723_1` | `g728` | `gem` |
| `gsm` | `gsm_ms` | `gsm_ms_at` | `hca` |
| `hcom` | `idcin` | `ilbc_at` | `indeo2` |
| `indeo3` | `indeo4` | `indeo5` | `ipu` |
| `jacosub` | `libaom_av1` | `libaribb24` | `libaribcaption` |
| `libcodec2` | `libdavs2` | `libfdk_aac` | `libgsm` |
| `libgsm_ms` | `libilbc` | `liblc3` | `libmpeghdec` |
| `libopencore_amrnb` | `libopencore_amrwb` | `libopenh264` | `librsvg` |
| `libspeex` | `libsvtjpegxs` | `libxevd` | `libzvbi_teletext` |
| `mdec` | `microdvd` | `mimic` | `movtext` |
| `nellymoser` | `pgssub` | `psd` | `qdm2` |
| `qdm2_at` | `qdmc` | `qdmc_at` | `realtext` |
| `roq_dpcm` | `sami` | `shorten` | `sipr` |
| `smacker` | `sol_dpcm` | `srt` | `ssa` |
| `stl` | `subrip` | `subviewer` | `subviewer1` |
| `thp` | `tiertexseqvideo` | `tmv` | `truespeech` |
| `txd` | `v210` | `v210x` | `vcr1` |
| `vmnc` | `vqa` | `webvtt` | `ws_snd1` |
| `xan_dpcm` | `xan_wc3` | `xan_wc4` | `xma1` |
| `xma2` | `xsub` | `zlib` | `zmbv` |

### 已过时的禁用列表 (Obsolete Disabled - 共 5 项)

- `libcelt`（n9.0.1 已移除）
- `sonic`（n9.0.1 已移除）
- `v308`（n9.0.1 已移除）
- `v408`（n9.0.1 已移除）
- `v410`（n9.0.1 已移除）

---

## 1.7 编码器 (Encoders / encoders)

编码器负责将未压缩的像素/PCM音频帧编码为特定格式的压缩数据流。

- **总支持数**：`269` 个
- **启用数量**：`5` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`264` 个 ｜ **已过时的禁用数量**：`7` 个

### 配置规则

```cmake
--disable-encoders
--enable-encoder=mjpeg,mjpeg_*,anull,vnull
```

### 配置解析与说明

1. **专注于播放器定位**：mpv 作为播放器，主要功能为多媒体解码播放，为控制库体积并提高构建效率，禁用了几乎所有重型视频/音频编码器（如 x264、x265、svt-av1、libmp3lame 等）。
2. **保留必要组件**：仅启用了用于截图保存/封面提取所需的 `mjpeg` 编码器，以及虚拟/占位编码器 `anull`、`vnull`。通配符 `mjpeg_*` 匹配到的硬件编码器（如 `mjpeg_qsv`、`mjpeg_vaapi`）因依赖未启用在实际构建中被跳过。

- `h264_rkmpp`、`hevc_rkmpp` 仅适用于 Rockchip SoC；`av1_d3d12va` 还要求构建头文件提供 `d3d12va_av1_headers`；`prores_ks_vulkan` 依赖 Vulkan 着色器编译链（当前 `--disable-vulkan`）。

### 启用列表 (Enabled - 共 5 项)

- `anull`
- `mjpeg`
- `mjpeg_qsv`
- `mjpeg_vaapi`
- `vnull`

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 264 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `a64multi` | `a64multi5` | `aac` | `aac_at` |
| `aac_mf` | `ac3` | `ac3_fixed` | `ac3_mf` |
| `adpcm_adx` | `adpcm_argo` | `adpcm_g722` | `adpcm_g726` |
| `adpcm_g726le` | `adpcm_ima_alp` | `adpcm_ima_amv` | `adpcm_ima_apm` |
| `adpcm_ima_qt` | `adpcm_ima_ssi` | `adpcm_ima_wav` | `adpcm_ima_ws` |
| `adpcm_ms` | `adpcm_swf` | `adpcm_yamaha` | `alac` |
| `alac_at` | `alias_pix` | `amv` | `apng` |
| `aptx` | `aptx_hd` | `ass` | `asv1` |
| `asv2` | `av1_amf` | `av1_d3d12va` | `av1_mediacodec` |
| `av1_mf` | `av1_nvenc` | `av1_qsv` | `av1_vaapi` |
| `av1_vulkan` | `avrp` | `avui` | `bitpacked` |
| `bmp` | `cfhd` | `cinepak` | `cljr` |
| `comfortnoise` | `dca` | `dfpwm` | `dnxhd` |
| `dpx` | `dvbsub` | `dvdsub` | `dvvideo` |
| `dxv` | `eac3` | `exr` | `ffv1` |
| `ffv1_vulkan` | `ffvhuff` | `fits` | `flac` |
| `flashsv` | `flashsv2` | `flv` | `g723_1` |
| `gif` | `h261` | `h263` | `h263_v4l2m2m` |
| `h263p` | `h264_amf` | `h264_d3d12va` | `h264_mediacodec` |
| `h264_mf` | `h264_nvenc` | `h264_oh` | `h264_qsv` |
| `h264_rkmpp` | `h264_v4l2m2m` | `h264_vaapi` | `h264_videotoolbox` |
| `h264_vulkan` | `hap` | `hdr` | `hevc_amf` |
| `hevc_d3d12va` | `hevc_mediacodec` | `hevc_mf` | `hevc_nvenc` |
| `hevc_oh` | `hevc_qsv` | `hevc_rkmpp` | `hevc_v4l2m2m` |
| `hevc_vaapi` | `hevc_videotoolbox` | `hevc_vulkan` | `huffyuv` |
| `ilbc_at` | `jpeg2000` | `jpegls` | `libaom_av1` |
| `libcodec2` | `libfdk_aac` | `libgsm` | `libgsm_ms` |
| `libilbc` | `libjxl` | `libjxl_anim` | `libkvazaar` |
| `liblc3` | `libmp3lame` | `liboapv` | `libopencore_amrnb` |
| `libopenh264` | `libopenjpeg` | `libopus` | `librav1e` |
| `libshine` | `libspeex` | `libsvtav1` | `libsvtjpegxs` |
| `libtheora` | `libtwolame` | `libvo_amrwbenc` | `libvorbis` |
| `libvpx_vp8` | `libvpx_vp9` | `libvvenc` | `libwebp` |
| `libwebp_anim` | `libx262` | `libx264` | `libx264rgb` |
| `libx265` | `libxavs` | `libxavs2` | `libxeve` |
| `libxvid` | `ljpeg` | `magicyuv` | `mlp` |
| `movtext` | `mp2` | `mp2fixed` | `mp3_mf` |
| `mpeg1video` | `mpeg2_qsv` | `mpeg2_vaapi` | `mpeg2video` |
| `mpeg4` | `mpeg4_mediacodec` | `mpeg4_v4l2m2m` | `msmpeg4v2` |
| `msmpeg4v3` | `msrle` | `msvideo1` | `nellymoser` |
| `opus` | `pam` | `pbm` | `pcm_alaw` |
| `pcm_alaw_at` | `pcm_bluray` | `pcm_dvd` | `pcm_f32be` |
| `pcm_f32le` | `pcm_f64be` | `pcm_f64le` | `pcm_mulaw` |
| `pcm_mulaw_at` | `pcm_s16be` | `pcm_s16be_planar` | `pcm_s16le` |
| `pcm_s16le_planar` | `pcm_s24be` | `pcm_s24daud` | `pcm_s24le` |
| `pcm_s24le_planar` | `pcm_s32be` | `pcm_s32le` | `pcm_s32le_planar` |
| `pcm_s64be` | `pcm_s64le` | `pcm_s8` | `pcm_s8_planar` |
| `pcm_u16be` | `pcm_u16le` | `pcm_u24be` | `pcm_u24le` |
| `pcm_u32be` | `pcm_u32le` | `pcm_u8` | `pcm_vidc` |
| `pcx` | `pdv` | `pfm` | `pgm` |
| `pgmyuv` | `phm` | `png` | `ppm` |
| `prores` | `prores_aw` | `prores_ks` | `prores_ks_vulkan` |
| `prores_videotoolbox` | `qoi` | `qtrle` | `r10k` |
| `r210` | `ra_144` | `rawvideo` | `roq` |
| `roq_dpcm` | `rpza` | `rv10` | `rv20` |
| `s302m` | `sbc` | `sgi` | `smc` |
| `snow` | `speedhq` | `srt` | `ssa` |
| `subrip` | `sunrast` | `svq1` | `targa` |
| `text` | `tiff` | `truehd` | `tta` |
| `ttml` | `utvideo` | `v210` | `vbn` |
| `vc2` | `vorbis` | `vp8_mediacodec` | `vp8_v4l2m2m` |
| `vp8_vaapi` | `vp9_mediacodec` | `vp9_qsv` | `vp9_vaapi` |
| `wavpack` | `wbmp` | `webvtt` | `wmav1` |
| `wmav2` | `wmv1` | `wmv2` | `wrapped_avframe` |
| `xbm` | `xface` | `xsub` | `xwd` |
| `y41p` | `yuv4` | `zlib` | `zmbv` |

### 已过时的禁用列表 (Obsolete Disabled - 共 7 项)

- `h264_omx`（n9.0.1 已移除）
- `mpeg4_omx`（n9.0.1 已移除）
- `sonic`（n9.0.1 已移除）
- `sonic_ls`（n9.0.1 已移除）
- `v308`（n9.0.1 已移除）
- `v408`（n9.0.1 已移除）
- `v410`（n9.0.1 已移除）

---

## 1.8 复用器 (Muxers / muxers)

复用器负责将编码后的音视频流、字幕及元数据按照特定容器规范（如 MP4、MKV、TS 等）打包封装为文件或输出流。

- **总支持数**：`185` 个
- **启用数量**：`4` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`181` 个 ｜ **已过时的禁用数量**：`0` 个

### 配置规则

```cmake
--disable-muxers
--enable-muxer=image2*,mjpeg,null
```

### 配置解析与说明

mpv 播放器本身极少需要封装输出文件，故禁用了绝大部分复杂容器复用器，仅启用了支持单帧/图片序列输出的 `image2`、`image2pipe`、`mjpeg` 以及空输出测试器 `null`。

### 启用列表 (Enabled - 共 4 项)

- `image2`
- `image2pipe`
- `mjpeg`
- `null`

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 181 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `a64` | `ac3` | `ac4` | `adts` |
| `adx` | `aea` | `aiff` | `alp` |
| `amr` | `amv` | `apm` | `apng` |
| `aptx` | `aptx_hd` | `apv` | `argo_asf` |
| `argo_cvg` | `asf` | `asf_stream` | `ass` |
| `ast` | `au` | `avi` | `avif` |
| `avm2` | `avs2` | `avs3` | `bit` |
| `caf` | `cavsvideo` | `chromaprint` | `codec2` |
| `codec2raw` | `crc` | `dash` | `data` |
| `daud` | `dfpwm` | `dirac` | `dnxhd` |
| `dts` | `dv` | `eac3` | `evc` |
| `f4v` | `ffmetadata` | `fifo` | `filmstrip` |
| `fits` | `flac` | `flv` | `framecrc` |
| `framehash` | `framemd5` | `g722` | `g723_1` |
| `g726` | `g726le` | `gif` | `gsm` |
| `gxf` | `h261` | `h263` | `h264` |
| `hash` | `hds` | `hevc` | `hls` |
| `iamf` | `ico` | `ilbc` | `ipod` |
| `ircam` | `ismv` | `ivf` | `jacosub` |
| `kvag` | `latm` | `lc3` | `lrc` |
| `m4v` | `matroska` | `matroska_audio` | `mcc` |
| `md5` | `microdvd` | `mkvtimestamp_v2` | `mlp` |
| `mmf` | `mov` | `mp2` | `mp3` |
| `mp4` | `mpeg1system` | `mpeg1vcd` | `mpeg1video` |
| `mpeg2dvd` | `mpeg2svcd` | `mpeg2video` | `mpeg2vob` |
| `mpegts` | `mpjpeg` | `mxf` | `mxf_d10` |
| `mxf_opatom` | `nut` | `obu` | `oga` |
| `ogg` | `ogv` | `oma` | `opus` |
| `pcm_alaw` | `pcm_f32be` | `pcm_f32le` | `pcm_f64be` |
| `pcm_f64le` | `pcm_mulaw` | `pcm_s16be` | `pcm_s16le` |
| `pcm_s24be` | `pcm_s24le` | `pcm_s32be` | `pcm_s32le` |
| `pcm_s8` | `pcm_u16be` | `pcm_u16le` | `pcm_u24be` |
| `pcm_u24le` | `pcm_u32be` | `pcm_u32le` | `pcm_u8` |
| `pcm_vidc` | `pdv` | `psp` | `rawvideo` |
| `rcwt` | `rm` | `roq` | `rso` |
| `rtp` | `rtp_mpegts` | `rtsp` | `sap` |
| `sbc` | `scc` | `segafilm` | `segment` |
| `smjpeg` | `smoothstreaming` | `sox` | `spdif` |
| `spx` | `srt` | `stream_segment` | `streamhash` |
| `sup` | `swf` | `tee` | `tg2` |
| `tgp` | `truehd` | `tta` | `ttml` |
| `uncodedframecrc` | `vc1` | `vc1t` | `voc` |
| `vvc` | `w64` | `wav` | `webm` |
| `webm_chunk` | `webm_dash_manifest` | `webp` | `webvtt` |
| `whip` | `wsaud` | `wtv` | `wv` |
| `yuv4mpegpipe` |  |  |  |

### 已过时的禁用列表 (Obsolete Disabled - 共 0 项)

*（无）*

---

## 1.9 解复用器 (Demuxers / demuxers)

解复用器负责解析各类多媒体文件容器或流媒体协议，分离出各个音轨、视轨、字幕轨及章节、元数据信息。

- **总支持数**：`367` 个
- **启用数量**：`244` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`123` 个 ｜ **已过时的禁用数量**：`0` 个

### 配置规则

```cmake
--disable-demuxers
--enable-demuxer=aa,aac,aax,ac3,ac4,aiff,alp,amr,amrnb,amrwb,apac,ape,apm,apng,apv,argo_asf,argo_brp,argo_cvg,asf,asf_o,ast,au,av1,avi,avr,avs,avs2,avs3,bintext,bit,bitpacked,caf,cavsvideo,cdg,cine,concat,dash,data,daud,derf,dfpwm,dirac,dnxhd,dsf,dsicin,dss,dts,dtshd,dv,eac3,evc,ffmetadata,filmstrip,fits,flac,flic,flv,g722,g726,g726le,g729,gif,h261,h263,h264,hcom,hevc,hls,hnm,iamf,ico,idcin,idf,iff,ifv,ilbc,image2*,image_*,ircam,iss,iv8,ivf,jpegxl_anim,lc3,live_flv,loas,luodat,m4v,matroska,mjpeg,mjpeg_2000,mlp,mlv,mov,mp3,mpc,mpc8,mpegps,mpegts,mpegtsraw,mpegvideo,mpjpeg,mtv,mv,mvi,mxf,mxg,nc,nistsphere,nsp,nsv,nut,obu,ogg,oma,osq,paf,pcm_*,pdv,pjs,pmp,pp_bnk,pva,pvf,qcp,qoa,r3d,rawvideo,rcwt,redspark,rka,rl2,rm,rsd,rso,s337m,sap,sbc,scd,sdp,sdr2,sdx,segafilm,ser,sga,siff,simbiosis_imx,sln,smjpeg,smush,sox,spdif,sup,swf,tak,threedostr,truehd,tta,ty,vc1,vc1t,vividas,vivo,vmd,voc,vqf,vvc,w64,wady,wav,wavarc,webm_dash_manifest,webp_anim,wsd,wsvqa,wtv,wv,wve,xa,xbin,xmd,xmv,xwma,yop,yuv4mpegpipe
```

### 配置解析与说明

广泛支持了播放器可能遇到的各类本地容器与流媒体封装（如 Matroska/WebM、MP4/MOV、FLV、MPEG-TS、AVI、OGG、WAV、FLAC、HLS、DASH 等），禁用了一些极端罕见、过时的工业或特定旧游戏格式解复用器。

- `webp_anim` 已按需启用，与同名解码器配合支持动态 WebP；`image_jpegxs_pipe` 命中 `image_*` 通配白名单而自动启用，但它只负责解封装，JPEG XS 的实际解码仍需引入外部库 `libsvtjpegxs`。

### 启用列表 (Enabled - 共 244 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `aa` | `aac` | `aax` | `ac3` |
| `ac4` | `aiff` | `alp` | `amr` |
| `amrnb` | `amrwb` | `apac` | `ape` |
| `apm` | `apng` | `apv` | `argo_asf` |
| `argo_brp` | `argo_cvg` | `asf` | `asf_o` |
| `ast` | `au` | `av1` | `avi` |
| `avr` | `avs` | `avs2` | `avs3` |
| `bintext` | `bit` | `bitpacked` | `caf` |
| `cavsvideo` | `cdg` | `cine` | `concat` |
| `dash` | `data` | `daud` | `derf` |
| `dfpwm` | `dirac` | `dnxhd` | `dsf` |
| `dsicin` | `dss` | `dts` | `dtshd` |
| `dv` | `eac3` | `evc` | `ffmetadata` |
| `filmstrip` | `fits` | `flac` | `flic` |
| `flv` | `g722` | `g726` | `g726le` |
| `g729` | `gif` | `h261` | `h263` |
| `h264` | `hcom` | `hevc` | `hls` |
| `hnm` | `iamf` | `ico` | `idcin` |
| `idf` | `iff` | `ifv` | `ilbc` |
| `image2` | `image2_alias_pix` | `image2_brender_pix` | `image2pipe` |
| `image_bmp_pipe` | `image_cri_pipe` | `image_dds_pipe` | `image_dpx_pipe` |
| `image_exr_pipe` | `image_gem_pipe` | `image_gif_pipe` | `image_hdr_pipe` |
| `image_j2k_pipe` | `image_jpeg_pipe` | `image_jpegls_pipe` | `image_jpegxl_pipe` |
| `image_jpegxs_pipe` | `image_pam_pipe` | `image_pbm_pipe` | `image_pcx_pipe` |
| `image_pfm_pipe` | `image_pgm_pipe` | `image_pgmyuv_pipe` | `image_pgx_pipe` |
| `image_phm_pipe` | `image_photocd_pipe` | `image_pictor_pipe` | `image_png_pipe` |
| `image_ppm_pipe` | `image_psd_pipe` | `image_qdraw_pipe` | `image_qoi_pipe` |
| `image_sgi_pipe` | `image_sunrast_pipe` | `image_svg_pipe` | `image_tiff_pipe` |
| `image_vbn_pipe` | `image_webp_pipe` | `image_xbm_pipe` | `image_xpm_pipe` |
| `image_xwd_pipe` | `ircam` | `iss` | `iv8` |
| `ivf` | `jpegxl_anim` | `lc3` | `live_flv` |
| `loas` | `luodat` | `m4v` | `matroska` |
| `mjpeg` | `mjpeg_2000` | `mlp` | `mlv` |
| `mov` | `mp3` | `mpc` | `mpc8` |
| `mpegps` | `mpegts` | `mpegtsraw` | `mpegvideo` |
| `mpjpeg` | `mtv` | `mv` | `mvi` |
| `mxf` | `mxg` | `nc` | `nistsphere` |
| `nsp` | `nsv` | `nut` | `obu` |
| `ogg` | `oma` | `osq` | `paf` |
| `pcm_alaw` | `pcm_f32be` | `pcm_f32le` | `pcm_f64be` |
| `pcm_f64le` | `pcm_mulaw` | `pcm_s16be` | `pcm_s16le` |
| `pcm_s24be` | `pcm_s24le` | `pcm_s32be` | `pcm_s32le` |
| `pcm_s8` | `pcm_u16be` | `pcm_u16le` | `pcm_u24be` |
| `pcm_u24le` | `pcm_u32be` | `pcm_u32le` | `pcm_u8` |
| `pcm_vidc` | `pdv` | `pjs` | `pmp` |
| `pp_bnk` | `pva` | `pvf` | `qcp` |
| `qoa` | `r3d` | `rawvideo` | `rcwt` |
| `redspark` | `rka` | `rl2` | `rm` |
| `rsd` | `rso` | `s337m` | `sap` |
| `sbc` | `scd` | `sdp` | `sdr2` |
| `sdx` | `segafilm` | `ser` | `sga` |
| `siff` | `simbiosis_imx` | `sln` | `smjpeg` |
| `smush` | `sox` | `spdif` | `sup` |
| `swf` | `tak` | `threedostr` | `truehd` |
| `tta` | `ty` | `vc1` | `vc1t` |
| `vividas` | `vivo` | `vmd` | `voc` |
| `vqf` | `vvc` | `w64` | `wady` |
| `wav` | `wavarc` | `webm_dash_manifest` | `webp_anim` |
| `wsd` | `wsvqa` | `wtv` | `wv` |
| `wve` | `xa` | `xbin` | `xmd` |
| `xmv` | `xwma` | `yop` | `yuv4mpegpipe` |

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 123 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `ace` | `acm` | `act` | `adf` |
| `adp` | `ads` | `adx` | `aea` |
| `afc` | `aix` | `anm` | `apc` |
| `aptx` | `aptx_hd` | `aqtitle` | `ass` |
| `avisynth` | `bethsoftvid` | `bfi` | `bfstm` |
| `bink` | `binka` | `bmv` | `boa` |
| `bonk` | `brstm` | `c93` | `cdxl` |
| `codec2` | `codec2raw` | `dcstr` | `dfa` |
| `dhav` | `dvbsub` | `dvbtxt` | `dvdvideo` |
| `dxa` | `ea` | `ea_cdata` | `epaf` |
| `fourxm` | `frm` | `fsb` | `fwse` |
| `g723_1` | `g728` | `gdv` | `genh` |
| `gsm` | `gxf` | `hca` | `hxvs` |
| `imf` | `ingenient` | `ipmovie` | `ipu` |
| `ivr` | `jacosub` | `jv` | `kux` |
| `kvag` | `laf` | `libgme` | `libmodplug` |
| `libopenmpt` | `lmlm4` | `lrc` | `lvf` |
| `lxf` | `mca` | `mcc` | `mgsts` |
| `microdvd` | `mm` | `mmf` | `mods` |
| `moflex` | `mpl2` | `mpsub` | `msf` |
| `msnwc_tcp` | `msp` | `mtaf` | `musx` |
| `nuv` | `realtext` | `roq` | `rpl` |
| `rtp` | `rtsp` | `sami` | `sbg` |
| `scc` | `sdns` | `sds` | `shorten` |
| `smacker` | `sol` | `srt` | `stl` |
| `str` | `subviewer` | `subviewer1` | `svag` |
| `svs` | `tedcaptions` | `thp` | `tiertexseq` |
| `tmv` | `tty` | `txd` | `usm` |
| `v210` | `v210x` | `vag` | `vapoursynth` |
| `vobsub` | `vpk` | `vplayer` | `wc3` |
| `webvtt` | `wsaud` | `xvag` |  |

### 已过时的禁用列表 (Obsolete Disabled - 共 0 项)

*（无）*

---

## 1.10 滤镜 (Filters / filters)

滤镜用于对音频采样或视频图像进行格式转换、重采样、空间/时间域特效、重混音、动态范围控制等处理。

- **总支持数**：`592` 个
- **启用数量**：`46` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`546` 个 ｜ **已过时的禁用数量**：`4` 个

### 配置规则

```cmake
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
```

### 配置解析与说明

1. **精炼聚焦**：FFmpeg 拥有多达 585 个滤镜，配置仅精准保留了 43 个与播放器音视频管线最关键的滤镜。
2. **核心音频与格式处理**：包括格式协商 (`format`, `aformat`, `noformat`)、硬件帧传输 (`hwdownload`, `hwupload`)、音频重采样与混音 (`aresample`, `amix`, `pan`)、音量及响度标准化 (`volume`, `loudnorm`, `volumedetect`, `acompressor`, `alimiter`, `equalizer`, `dialoguenhance`)，以及耳机双耳环绕算法 `bs2b`（依赖启用 `--enable-libbs2b`）。
3. **视频处理由外部库接管**：复杂的视频缩放、色调映射、后处理滤镜在 mpv 中主要交由 libplacebo、Vulkan/D3D 着色器完成，因此未启用大量复杂的 FFmpeg 视频软滤镜。

- `scale_d3d12`、`deinterlace_d3d12`、`mestimate_d3d12` 已按需启用（依赖已生效的 `--enable-d3d12va`，并需 mingw-w64 头文件提供 `ID3D12VideoProcessor`/`ID3D12VideoMotionEstimator`）。
- `drawvg` 因需要 cairo 依赖未启用；`gfxcapture`、`amf_capture`、`transpose_cuda` 属"仅需追加白名单即可启用"的候选；`ocio`、`v360_vulkan` 分别需要 OpenColorIO 库与 `--enable-vulkan`。

### 启用列表 (Enabled - 共 46 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `acompressor` | `acopy` | `aecho` | `aformat` |
| `alimiter` | `amix` | `amovie` | `anull` |
| `anullsink` | `anullsrc` | `apulsator` | `aresample` |
| `areverse` | `aselect` | `atempo` | `atrim` |
| `bass` | `bs2b` | `compand` | `copy` |
| `deinterlace_d3d12` | `dialoguenhance` | `equalizer` | `format` |
| `hwdownload` | `hwupload` | `loudnorm` | `mestimate_d3d12` |
| `metadata` | `noformat` | `null` | `nullsink` |
| `nullsrc` | `pan` | `reverse` | `scale_d3d12` |
| `silencedetect` | `silenceremove` | `sinc` | `sine` |
| `stereotools` | `stereowiden` | `tremolo` | `vibrato` |
| `volume` | `volumedetect` |  |  |

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无）*

### 禁用列表 (Disabled - 共 546 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `a3dscope` | `aap` | `abench` | `abitscope` |
| `acontrast` | `acrossfade` | `acrossover` | `acrusher` |
| `acue` | `addroi` | `adeclick` | `adeclip` |
| `adecorrelate` | `adelay` | `adenorm` | `aderivative` |
| `adrawgraph` | `adrc` | `adynamicequalizer` | `adynamicsmooth` |
| `aemphasis` | `aeval` | `aevalsrc` | `aexciter` |
| `afade` | `afdelaysrc` | `afftdn` | `afftfilt` |
| `afir` | `afireqsrc` | `afirsrc` | `afreqshift` |
| `afwtdn` | `agate` | `agraphmonitor` | `ahistogram` |
| `aiir` | `aintegral` | `ainterleave` | `alatency` |
| `allpass` | `allrgb` | `allyuv` | `aloop` |
| `alphaextract` | `alphamerge` | `amerge` | `ametadata` |
| `amf_capture` | `amplify` | `amultiply` | `anequalizer` |
| `anlmdn` | `anlmf` | `anlms` | `anoisesrc` |
| `apad` | `aperms` | `aphasemeter` | `aphaser` |
| `aphaseshift` | `apsnr` | `apsyclip` | `arealtime` |
| `arls` | `arnndn` | `asdr` | `asegment` |
| `asendcmd` | `asetnsamples` | `asetpts` | `asetrate` |
| `asettb` | `ashowinfo` | `asidedata` | `asisdr` |
| `asoftclip` | `aspectralstats` | `asplit` | `asr` |
| `ass` | `astats` | `astreamselect` | `asubboost` |
| `asubcut` | `asupercut` | `asuperpass` | `asuperstop` |
| `atadenoise` | `atilt` | `avectorscope` | `avgblur` |
| `avgblur_opencl` | `avgblur_vulkan` | `avsynctest` | `axcorrelate` |
| `azmq` | `backgroundkey` | `bandpass` | `bandreject` |
| `bbox` | `bench` | `bilateral` | `bilateral_cuda` |
| `biquad` | `bitplanenoise` | `blackdetect` | `blackdetect_vulkan` |
| `blackframe` | `blend` | `blend_vulkan` | `blockdetect` |
| `blurdetect` | `bm3d` | `boxblur` | `boxblur_opencl` |
| `bwdif` | `bwdif_cuda` | `bwdif_vulkan` | `cas` |
| `ccrepack` | `cellauto` | `channelmap` | `channelsplit` |
| `chorus` | `chromaber_vulkan` | `chromahold` | `chromakey` |
| `chromakey_cuda` | `chromanr` | `chromashift` | `ciescope` |
| `codecview` | `color` | `color_vulkan` | `colorbalance` |
| `colorchannelmixer` | `colorchart` | `colorcontrast` | `colorcorrect` |
| `colordetect` | `colorhold` | `colorize` | `colorkey` |
| `colorkey_opencl` | `colorlevels` | `colormap` | `colormatrix` |
| `colorspace` | `colorspace_cuda` | `colorspectrum` | `colortemperature` |
| `compensationdelay` | `concat` | `convolution` | `convolution_opencl` |
| `convolve` | `coreimage` | `coreimagesrc` | `corr` |
| `cover_rect` | `crop` | `cropdetect` | `crossfeed` |
| `crystalizer` | `cue` | `curves` | `datascope` |
| `dblur` | `dcshift` | `dctdnoiz` | `ddagrab` |
| `deband` | `deblock` | `decimate` | `deconvolve` |
| `dedot` | `deesser` | `deflate` | `deflicker` |
| `deinterlace_qsv` | `deinterlace_vaapi` | `dejudder` | `delogo` |
| `denoise_vaapi` | `derain` | `deshake` | `deshake_opencl` |
| `despill` | `detelecine` | `dilation` | `dilation_opencl` |
| `displace` | `dnn_classify` | `dnn_detect` | `dnn_processing` |
| `doubleweave` | `drawbox` | `drawbox_vaapi` | `drawgraph` |
| `drawgrid` | `drawtext` | `drawvg` | `drmeter` |
| `dynaudnorm` | `earwax` | `ebur128` | `edgedetect` |
| `elbg` | `entropy` | `epx` | `eq` |
| `erosion` | `erosion_opencl` | `estdif` | `exposure` |
| `extractplanes` | `extrastereo` | `fade` | `feedback` |
| `fftdnoiz` | `fftfilt` | `field` | `fieldhint` |
| `fieldmatch` | `fieldorder` | `fillborders` | `find_rect` |
| `firequalizer` | `flanger` | `flip_vulkan` | `flite` |
| `floodfill` | `fps` | `framepack` | `framerate` |
| `framestep` | `frc_amf` | `freezedetect` | `freezeframes` |
| `frei0r` | `frei0r_src` | `fspp` | `fsync` |
| `gblur` | `gblur_vulkan` | `geq` | `gfxcapture` |
| `gradfun` | `gradients` | `graphmonitor` | `grayworld` |
| `greyedge` | `guided` | `haas` | `haldclut` |
| `haldclutsrc` | `hdcd` | `headphone` | `hflip` |
| `hflip_vulkan` | `highpass` | `highshelf` | `hilbert` |
| `histeq` | `histogram` | `hqdn3d` | `hqx` |
| `hstack` | `hstack_qsv` | `hstack_vaapi` | `hsvhold` |
| `hsvkey` | `hue` | `huesaturation` | `hwmap` |
| `hwupload_cuda` | `hysteresis` | `iccdetect` | `iccgen` |
| `identity` | `idet` | `il` | `inflate` |
| `interlace` | `interlace_vulkan` | `interleave` | `join` |
| `kerndeint` | `kirsch` | `ladspa` | `lagfun` |
| `latency` | `lcevc` | `lenscorrection` | `lensfun` |
| `libplacebo` | `libvmaf` | `libvmaf_cuda` | `life` |
| `limitdiff` | `limiter` | `loop` | `lowpass` |
| `lowshelf` | `lumakey` | `lut` | `lut1d` |
| `lut2` | `lut3d` | `lutrgb` | `lutyuv` |
| `lv2` | `mandelbrot` | `maskedclamp` | `maskedmax` |
| `maskedmerge` | `maskedmin` | `maskedthreshold` | `maskfun` |
| `mcdeint` | `mcompand` | `median` | `mergeplanes` |
| `mestimate` | `midequalizer` | `minterpolate` | `mix` |
| `monochrome` | `morpho` | `movie` | `mpdecimate` |
| `mptestsrc` | `msad` | `multiply` | `negate` |
| `nlmeans` | `nlmeans_opencl` | `nlmeans_vulkan` | `nnedi` |
| `noise` | `normalize` | `ocio` | `ocr` |
| `ocv` | `openclsrc` | `oscilloscope` | `overlay` |
| `overlay_cuda` | `overlay_opencl` | `overlay_qsv` | `overlay_vaapi` |
| `overlay_vulkan` | `owdenoise` | `pad` | `pad_cuda` |
| `pad_opencl` | `pad_vaapi` | `pal100bars` | `pal75bars` |
| `palettegen` | `paletteuse` | `perlin` | `perms` |
| `perspective` | `phase` | `photosensitivity` | `pixdesctest` |
| `pixelize` | `pixscope` | `pp7` | `premultiply` |
| `premultiply_dynamic` | `prewitt` | `prewitt_opencl` | `procamp_vaapi` |
| `program_opencl` | `pseudocolor` | `psnr` | `pullup` |
| `qp` | `qrencode` | `qrencodesrc` | `quirc` |
| `random` | `readeia608` | `readvitc` | `realtime` |
| `remap` | `remap_opencl` | `removegrain` | `removelogo` |
| `repeatfields` | `replaygain` | `rgbashift` | `rgbtestsrc` |
| `roberts` | `roberts_opencl` | `rotate` | `rubberband` |
| `sab` | `scale` | `scale2ref` | `scale_cuda` |
| `scale_d3d11` | `scale_qsv` | `scale_vaapi` | `scale_vt` |
| `scale_vulkan` | `scdet` | `scdet_vulkan` | `scharr` |
| `scroll` | `segment` | `select` | `selectivecolor` |
| `sendcmd` | `separatefields` | `setdar` | `setfield` |
| `setparams` | `setpts` | `setrange` | `setsar` |
| `settb` | `sharpness_vaapi` | `shear` | `showcqt` |
| `showcwt` | `showfreqs` | `showinfo` | `showpalette` |
| `showspatial` | `showspectrum` | `showspectrumpic` | `showvolume` |
| `showwaves` | `showwavespic` | `shuffleframes` | `shufflepixels` |
| `shuffleplanes` | `sidechaincompress` | `sidechaingate` | `sidedata` |
| `sierpinski` | `signalstats` | `signature` | `siti` |
| `smartblur` | `smptebars` | `smptehdbars` | `sobel` |
| `sobel_opencl` | `sofalizer` | `spectrumsynth` | `speechnorm` |
| `split` | `spp` | `sr` | `sr_amf` |
| `ssim` | `ssim360` | `stereo3d` | `streamselect` |
| `subtitles` | `super2xsai` | `superequalizer` | `surround` |
| `swaprect` | `swapuv` | `tblend` | `telecine` |
| `testsrc` | `testsrc2` | `thistogram` | `threshold` |
| `thumbnail` | `thumbnail_cuda` | `tile` | `tiltandshift` |
| `tiltshelf` | `tinterlace` | `tlut2` | `tmedian` |
| `tmidequalizer` | `tmix` | `tonemap` | `tonemap_opencl` |
| `tonemap_vaapi` | `tpad` | `transpose` | `transpose_cuda` |
| `transpose_opencl` | `transpose_vaapi` | `transpose_vt` | `transpose_vulkan` |
| `treble` | `trim` | `unpremultiply` | `unsharp` |
| `unsharp_opencl` | `untile` | `uspp` | `v360` |
| `v360_vulkan` | `vaguedenoiser` | `varblur` | `vectorscope` |
| `vflip` | `vflip_vulkan` | `vfrdet` | `vibrance` |
| `vidstabdetect` | `vidstabtransform` | `vif` | `vignette` |
| `virtualbass` | `vmafmotion` | `vpp_amf` | `vpp_qsv` |
| `vstack` | `vstack_qsv` | `vstack_vaapi` | `w3fdif` |
| `waveform` | `weave` | `whisper` | `xbr` |
| `xcorrelate` | `xfade` | `xfade_opencl` | `xfade_vulkan` |
| `xmedian` | `xpsnr` | `xstack` | `xstack_qsv` |
| `xstack_vaapi` | `yadif` | `yadif_cuda` | `yadif_videotoolbox` |
| `yaepblur` | `yuvtestsrc` | `zmq` | `zoneplate` |
| `zoompan` | `zscale` |  |  |

### 已过时的禁用列表 (Obsolete Disabled - 共 4 项)

- `scale2ref_npp`（n9.0.1 已移除）
- `scale_npp`（n9.0.1 已移除）
- `sharpen_npp`（n9.0.1 已移除）
- `transpose_npp`（n9.0.1 已移除）

---

## 1.11 协议 (Protocols / protocols)

协议层负责处理网络传输协议、本地文件系统访问、内存管道或加密数据流传输。

- **总支持数**：`55` 个
- **启用数量**：`13` 个 ｜ **已过时的启用数量**：`0` 个
- **禁用数量**：`42` 个 ｜ **已过时的禁用数量**：`1` 个

### 配置规则

```cmake
--disable-protocols
--enable-protocol=async,cache,crypto,data,file,pipe,http,https,httpproxy,subfile,tcp,udp,tls
```

### 配置解析与说明

精简启用了网络流媒体播放、本地文件播放和代理所需的核心协议集合（包括 `file`、`pipe`、`http`、`https`、`httpproxy`、`tcp`、`udp`、`tls`、`crypto`、`cache`、`async`、`data`、`subfile` 等），排除了未使用的 FTP、Gopher、RTMP、SCTP 等协议；HLS 播放由 `hls` 解复用器配合 HTTP/TLS 协议栈承担。

- `shared` 协议依赖 POSIX `mmap`/`unistd.h`，Windows（MinGW）目标不满足，configure 阶段会被剔除。

### 启用列表 (Enabled - 共 13 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `async` | `cache` | `crypto` | `data` |
| `file` | `http` | `httpproxy` | `https` |
| `pipe` | `subfile` | `tcp` | `tls` |
| `udp` |  |  |  |

### 已过时的启用列表 (Obsolete Enabled - 共 0 项)

*（无 —— 原失效条目 `hls` 已随配置清理，归入下方"已过时的禁用"）*

### 禁用列表 (Disabled - 共 42 项)

| 组件名称 | 组件名称 | 组件名称 | 组件名称 |
| :--- | :--- | :--- | :--- |
| `android_content` | `bluray` | `concat` | `concatf` |
| `dtls` | `fd` | `ffrtmpcrypt` | `ffrtmphttp` |
| `ftp` | `gopher` | `gophers` | `icecast` |
| `ipfs_gateway` | `ipns_gateway` | `libamqp` | `librist` |
| `librtmp` | `librtmpe` | `librtmps` | `librtmpt` |
| `librtmpte` | `libsmbclient` | `libsrt` | `libssh` |
| `libzmq` | `md5` | `mmsh` | `mmst` |
| `prompeg` | `rtmp` | `rtmpe` | `rtmps` |
| `rtmpt` | `rtmpte` | `rtmpts` | `rtp` |
| `sctp` | `shared` | `srtp` | `tee` |
| `udplite` | `unix` |  |  |

### 已过时的禁用列表 (Obsolete Disabled - 共 1 项)

- `hls`（n9.0.1 已移除）

---
# 第二部分：FFmpeg configure 全局参数配置清单

> 本部分提取自 ffmpeg.cmake 所用 FFmpeg 版本的 configure 参数体系，结合 **`packages/ffmpeg.cmake`** 中的构建参数进行全面对照与分析。
> 本部分**排除了**动态组件参数（如 `--enable-protocol=...`、`--enable-decoder=...` 等已在第一部分详细展开的项），专注于全局系统开关、编译特征、第三方库与工具链配置。
>
> 每个模块按 **启用 / 已过时的启用 / 禁用 / 已过时的禁用** 四类拆分；带值参数（`--KEY=VALUE`）单独成表——它们不属于开关型参数，不计入启用/禁用分类。

## 2.1 全局参数总体统计汇总

| 参数分类模块 | 模块英文标识 | 启用参数项 (Enabled) | 已过时的启用 (Obsolete) | 禁用参数项 (Disabled) | 已过时的禁用 (Obsolete) | 带值配置参数项 (Key-Value) | 模块职能简述 |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **授权与许可协议** | `Licensing Options` | **2** | **0** | **1** | **0** | **0** | 控制 GPL、Version 3 和 Nonfree 协议升级及分发属性 |
| **库构建模式与通用配置** | `Configuration Options` | **6** | **0** | **4** | **0** | **0** | 静态库/动态库、体积优化、色彩通道及全量开关 |
| **命令行程序选项** | `Program Options` | **0** | **0** | **4** | **0** | **0** | ffmpeg、ffplay、ffprobe 独立二进制工具的编译开关 |
| **文档与手册页面** | `Documentation Options` | **0** | **0** | **5** | **0** | **0** | HTML/Man/Pod/Txt 各格式官方文档的生成开关 |
| **核心组件库与内置子系统** | `Component Options` | **17** | **0** | **0** | **0** | **0** | libavcodec、libavformat 等核心库及线程、网络子系统 |
| **外部第三方库支持** | `External Library Support` | **17** | **0** | **117** | **3** | **0** | 所链接的音视频、图像、协议及辅助外部开源库 |
| **硬件加速功能** | `Hardware Acceleration Features` | **10** | **0** | **13** | **3** | **0** | CUDA、CUVID、D3D11/12VA、AMF、QSV/VPL 等硬解与硬件编码接口 |
| **架构与指令集优化选项** | `Optimization Options` | **48** | **0** | **0** | **2** | **0** | 内联汇编、LTO、运行时CPU检测及各CPU指令集优化 |
| **开发与调试测试选项** | `Developer & Debugging Options` | **7** | **0** | **13** | **1** | **6** | 调试符号、寄存器破坏测试、版本追踪及性能监测工具 |
| **高级内核选项** | `Advanced Options` | **2** | **0** | **0** | **0** | **3** | 自定义内存分配器、安全比特流读取器等底层调节 |
| **构建工具链与编译选项** | `Toolchain Options` | **4** | **0** | **1** | **0** | **55** | 交叉编译工具链（Clang/LLVM）、C/C++语言标准及编译旗标 |
| **标准安装路径与环境选项** | `Standard Options` | **1** | **0** | **4** | **0** | **11** | 安装前缀、库路径、头文件路径及日志开关 |
| **合计** | - | **114** | **0** | **162** | **9** | **75** | - |

> 与起点版本（n8.0.2）的对照：启用参数 104 → **114**；禁用参数 161 → **162**；带值配置参数 72 → **75**；另有 **9 个"已过时的禁用"**（即上游 n9.0.1 移除的 9 个参数，其中 `--disable-amd3dnow`、`--disable-amd3dnowext`、`--disable-ptx-compression` 3 项原为默认开启项）。

---

## 2.2 授权与许可协议 (Licensing Options)

控制 GPL、Version 3 和 Nonfree 协议升级及分发属性

- **启用参数数**：`2` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`1` 项 ｜ **已过时的禁用参数数**：`0` 项

### 启用参数列表 (Enabled - 共 2 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-nonfree` | **【显式启用】cmake 配置** | allow use of nonfree code, the resulting libs and binaries will be unredistributable [no] |
| `--enable-version3` | **【显式启用】cmake 配置** | upgrade (L)GPL to version 3 [no] |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 1 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-gpl` | **【显式禁用】cmake 配置** | allow use of GPL code, the resulting libs and binaries will be under GPL [no] |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

---

## 2.3 库构建模式与通用配置 (Configuration Options)

静态库/动态库、体积优化、色彩通道及全量开关

- **启用参数数**：`6` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`4` 项 ｜ **已过时的禁用参数数**：`0` 项

### 启用参数列表 (Enabled - 共 6 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-all` | **【未触发】组件正常构建** | 禁用全部组件、库及程序构建（默认不触发） |
| `--disable-autodetect` | **【未触发】保持自动检测** | 禁用外部库自动探测（默认不触发，保留自动检测） |
| `--disable-checkasm` | **【默认启用】FFmpeg 默认开启** | disable building the checkasm test binary [no]（configure 内 `enable checkasm` 默认开启；本构建未配置该关闭项，checkasm 基准测试二进制默认构建，仅开发测试用、不进入库产物） |
| `--disable-unstable` | **【默认启用】FFmpeg 默认开启** | disable building optional unstable / experimental code（configure 内 `enable unstable` 默认开启；本构建未配置该关闭项，且当前源码树中暂无组件以它为依赖门控，不影响组件构建结果） |
| `--enable-runtime-cpudetect` | **【显式启用】cmake 配置** | disable detecting CPU capabilities at runtime (smaller binary) |
| `--enable-static` | **【显式启用】cmake 配置** | do not build static libraries [no] |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 4 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-gray` | **【显式禁用】cmake 配置** | enable full grayscale support (slower color) |
| `--disable-shared` | **【显式禁用】cmake 配置** | build shared libraries [no] |
| `--disable-small` | **【默认禁用】FFmpeg 默认关闭** | optimize for size instead of speed |
| `--disable-swscale-alpha` | **【显式禁用】cmake 配置** | disable alpha channel support in swscale |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

---

## 2.4 命令行程序选项 (Program Options)

ffmpeg、ffplay、ffprobe 独立二进制工具的编译开关

- **启用参数数**：`0` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`4` 项 ｜ **已过时的禁用参数数**：`0` 项

### 启用参数列表 (Enabled - 共 0 项)

*（无参数）*

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 4 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-ffmpeg` | **【禁用】因 --disable-programs 级联禁用** | disable ffmpeg build |
| `--disable-ffplay` | **【禁用】因 --disable-programs 级联禁用** | disable ffplay build |
| `--disable-ffprobe` | **【禁用】因 --disable-programs 级联禁用** | disable ffprobe build |
| `--disable-programs` | **【显式禁用】cmake 配置** | do not build command line programs |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

---

## 2.5 文档与手册页面 (Documentation Options)

HTML/Man/Pod/Txt 各格式官方文档的生成开关

- **启用参数数**：`0` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`5` 项 ｜ **已过时的禁用参数数**：`0` 项

### 启用参数列表 (Enabled - 共 0 项)

*（无参数）*

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 5 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-doc` | **【显式禁用】cmake 配置** | do not build documentation |
| `--disable-htmlpages` | **【显式禁用】cmake 配置** | do not build HTML documentation pages |
| `--disable-manpages` | **【显式禁用】cmake 配置** | do not build man documentation pages |
| `--disable-podpages` | **【显式禁用】cmake 配置** | do not build POD documentation pages |
| `--disable-txtpages` | **【显式禁用】cmake 配置** | do not build text documentation pages |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

---

## 2.6 核心组件库与内置子系统 (Component Options)

libavcodec、libavformat 等核心库及线程、网络子系统

- **启用参数数**：`17` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`0` 项 ｜ **已过时的禁用参数数**：`0` 项

### 启用参数列表 (Enabled - 共 17 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-avcodec` | **【显式启用】cmake 配置** | disable libavcodec build |
| `--enable-avdevice` | **【显式启用】cmake 配置** | disable libavdevice build |
| `--enable-avfilter` | **【显式启用】cmake 配置** | disable libavfilter build |
| `--enable-avformat` | **【显式启用】cmake 配置** | disable libavformat build |
| `--enable-dwt` | **【默认启用】FFmpeg 默认开启** | disable DWT code |
| `--enable-error-resilience` | **【默认启用】FFmpeg 默认开启** | disable error resilience code |
| `--enable-faan` | **【默认启用】FFmpeg 默认开启** | disable floating point AAN (I)DCT code |
| `--enable-hwaccels` | **【显式启用】cmake 配置** | disable all hwaccels（本构建显式启用全部硬件加速器组；具体 hwaccel 再由白名单与依赖筛选） |
| `--enable-iamf` | **【默认启用】FFmpeg 默认开启** | disable support for Immersive Audio Model |
| `--enable-lsp` | **【默认启用】FFmpeg 默认开启** | disable LSP code |
| `--enable-network` | **【显式启用】cmake 配置** | disable network support [no] |
| `--enable-os2threads` | **【默认启用】FFmpeg 默认开启** | disable OS/2 threads [autodetect] |
| `--enable-pixelutils` | **【默认启用】FFmpeg 默认开启** | disable pixel utils in libavutil |
| `--enable-pthreads` | **【默认启用】FFmpeg 默认开启** | disable pthreads [autodetect] |
| `--enable-swresample` | **【显式启用】cmake 配置** | disable libswresample build |
| `--enable-swscale` | **【显式启用】cmake 配置** | disable libswscale build |
| `--enable-w32threads` | **【默认启用】FFmpeg 默认开启** | disable Win32 threads [autodetect] |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 0 项)

*（无参数）*

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

---

## 2.7 外部第三方库支持 (External Library Support)

所链接的音视频、图像、协议及辅助外部开源库

- **启用参数数**：`17` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`117` 项 ｜ **已过时的禁用参数数**：`3` 项

### 启用参数列表 (Enabled - 共 17 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-bzlib` | **【显式启用】cmake 配置** | disable bzlib [autodetect] |
| `--enable-iconv` | **【显式启用】cmake 配置** | disable iconv [autodetect] |
| `--enable-lcms2` | **【显式启用】cmake 配置** | enable ICC profile support via LittleCMS 2 [no] |
| `--enable-libbs2b` | **【显式启用】cmake 配置** | enable bs2b DSP library [no] |
| `--enable-libdav1d` | **【显式启用】cmake 配置** | enable AV1 decoding via libdav1d [no] |
| `--enable-libjxl` | **【显式启用】cmake 配置** | enable JPEG XL de/encoding via libjxl [no] |
| `--enable-libopus` | **【显式启用】cmake 配置** | enable Opus de/encoding via libopus [no] |
| `--enable-libsoxr` | **【显式启用】cmake 配置** | enable Include libsoxr resampling [no] |
| `--enable-libuavs3d` | **【显式启用】cmake 配置** | enable AVS3 decoding via libuavs3d [no] |
| `--enable-libvorbis` | **【显式启用】cmake 配置** | enable Vorbis en/decoding via libvorbis, native implementation exists [no] |
| `--enable-libvpx` | **【显式启用】cmake 配置** | enable VP8 and VP9 de/encoding via libvpx [no] |
| `--enable-libwebp` | **【显式启用】cmake 配置** | enable WebP encoding via libwebp [no] |
| `--enable-libxml2` | **【显式启用】cmake 配置** | enable XML parsing using the C library libxml2, needed for dash and imf demuxing support [no] |
| `--enable-libzimg` | **【显式启用】cmake 配置** | enable z.lib, needed for zscale filter [no] |
| `--enable-lzma` | **【显式启用】cmake 配置** | disable lzma [autodetect] |
| `--enable-openssl` | **【显式启用】cmake 配置** | enable openssl, needed for https support if gnutls, libtls or mbedtls is not used [no] |
| `--enable-zlib` | **【显式启用】cmake 配置** | disable zlib [autodetect] |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 117 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-alsa` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable ALSA support [autodetect] |
| `--disable-appkit` | **【显式禁用】cmake 配置** | disable Apple AppKit framework [autodetect] |
| `--disable-avfoundation` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable Apple AVFoundation framework [autodetect] |
| `--disable-avisynth` | **【显式禁用】cmake 配置** | enable reading of AviSynth script files [no] |
| `--disable-cairo` | **【默认禁用】FFmpeg 默认关闭** | enable cairo [no]（2D 矢量渲染库，`drawvg` 滤镜依赖它） |
| `--disable-chromaprint` | **【默认禁用】FFmpeg 默认关闭** | enable audio fingerprinting with chromaprint [no] |
| `--disable-coreimage` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable Apple CoreImage framework [autodetect] |
| `--disable-decklink` | **【默认禁用】FFmpeg 默认关闭** | enable Blackmagic DeckLink I/O support [no] |
| `--disable-frei0r` | **【默认禁用】FFmpeg 默认关闭** | enable frei0r video filtering [no] |
| `--disable-gcrypt` | **【默认禁用】FFmpeg 默认关闭** | enable gcrypt, needed for rtmp(t)e support if openssl, librtmp or gmp is not used [no] |
| `--disable-gmp` | **【默认禁用】FFmpeg 默认关闭** | enable gmp, needed for rtmp(t)e support if openssl or librtmp is not used [no] |
| `--disable-gnutls` | **【默认禁用】FFmpeg 默认关闭** | enable gnutls, needed for https support if openssl, libtls or mbedtls is not used [no] |
| `--disable-jni` | **【默认禁用】FFmpeg 默认关闭** | enable JNI support [no] |
| `--disable-ladspa` | **【默认禁用】FFmpeg 默认关闭** | enable LADSPA audio filtering [no] |
| `--disable-libaom` | **【显式禁用】cmake 配置** | enable AV1 video encoding/decoding via libaom [no] |
| `--disable-libaribb24` | **【默认禁用】FFmpeg 默认关闭** | enable ARIB text and caption decoding via libaribb24 [no] |
| `--disable-libaribcaption` | **【显式禁用】cmake 配置** | enable ARIB text and caption decoding via libaribcaption [no] |
| `--disable-libass` | **【显式禁用】cmake 配置** | enable libass subtitles rendering, needed for subtitles and ass filter [no] |
| `--disable-libbluray` | **【显式禁用】cmake 配置** | enable BluRay reading using libbluray [no] |
| `--disable-libcaca` | **【默认禁用】FFmpeg 默认关闭** | enable textual display using libcaca [no] |
| `--disable-libcdio` | **【默认禁用】FFmpeg 默认关闭** | enable audio CD grabbing with libcdio [no] |
| `--disable-libcodec2` | **【默认禁用】FFmpeg 默认关闭** | enable codec2 en/decoding using libcodec2 [no] |
| `--disable-libdavs2` | **【默认禁用】FFmpeg 默认关闭** | enable AVS2 decoding via libdavs2 [no] |
| `--disable-libdc1394` | **【默认禁用】FFmpeg 默认关闭** | enable IIDC-1394 grabbing using libdc1394 and libraw1394 [no] |
| `--disable-libdvdnav` | **【显式禁用】cmake 配置** | enable libdvdnav, needed for DVD demuxing [no] |
| `--disable-libdvdread` | **【显式禁用】cmake 配置** | enable libdvdread, needed for DVD demuxing [no] |
| `--disable-libfdk-aac` | **【默认禁用】FFmpeg 默认关闭** | enable AAC de/encoding via libfdk-aac [no] |
| `--disable-libflite` | **【默认禁用】FFmpeg 默认关闭** | enable flite (voice synthesis) support via libflite [no] |
| `--disable-libfontconfig` | **【显式禁用】cmake 配置** | enable libfontconfig, useful for drawtext filter [no] |
| `--disable-libfreetype` | **【显式禁用】cmake 配置** | enable libfreetype, needed for drawtext filter [no] |
| `--disable-libfribidi` | **【显式禁用】cmake 配置** | enable libfribidi, improves drawtext filter [no] |
| `--disable-libgme` | **【默认禁用】FFmpeg 默认关闭** | enable Game Music Emu via libgme [no] |
| `--disable-libgsm` | **【默认禁用】FFmpeg 默认关闭** | enable GSM de/encoding via libgsm [no] |
| `--disable-libharfbuzz` | **【显式禁用】cmake 配置** | enable libharfbuzz, needed for drawtext filter [no] |
| `--disable-libiec61883` | **【默认禁用】FFmpeg 默认关闭** | enable iec61883 via libiec61883 [no] |
| `--disable-libilbc` | **【默认禁用】FFmpeg 默认关闭** | enable iLBC de/encoding via libilbc [no] |
| `--disable-libjack` | **【默认禁用】FFmpeg 默认关闭** | enable JACK audio sound server [no] |
| `--disable-libklvanc` | **【默认禁用】FFmpeg 默认关闭** | enable Kernel Labs VANC processing [no] |
| `--disable-libkvazaar` | **【默认禁用】FFmpeg 默认关闭** | enable HEVC encoding via libkvazaar [no] |
| `--disable-liblc3` | **【默认禁用】FFmpeg 默认关闭** | enable LC3 de/encoding via liblc3 [no] |
| `--disable-liblcevc-dec` | **【默认禁用】FFmpeg 默认关闭** | enable LCEVC decoding via liblcevc-dec [no] |
| `--disable-liblensfun` | **【默认禁用】FFmpeg 默认关闭** | enable lensfun lens correction [no] |
| `--disable-libmodplug` | **【显式禁用】cmake 配置** | enable ModPlug via libmodplug [no] |
| `--disable-libmp3lame` | **【显式禁用】cmake 配置** | enable MP3 encoding via libmp3lame [no] |
| `--disable-libmpeghdec` | **【默认禁用】FFmpeg 默认关闭** | enable MPEG-H 3DA decoding via libmpeghdec [no]（MPEG-H 3D Audio 空间音频解码，对应解码器 `libmpeghdec`） |
| `--disable-libmysofa` | **【显式禁用】cmake 配置** | enable libmysofa, needed for sofalizer filter [no] |
| `--disable-liboapv` | **【默认禁用】FFmpeg 默认关闭** | enable APV encoding via liboapv [no] |
| `--disable-libonnxruntime` | **【默认禁用】FFmpeg 默认关闭** | enable ONNX Runtime as a DNN module backend [no]（微软 ONNX Runtime 推理后端，供 DNN 类滤镜使用；本构建无 AI 滤镜需求） |
| `--disable-libopencolorio` | **【默认禁用】FFmpeg 默认关闭** | enable color management via OpenColorIO [no]（工业级色彩管理，`ocio` 滤镜依赖） |
| `--disable-libopencore-amrnb` | **【默认禁用】FFmpeg 默认关闭** | enable AMR-NB de/encoding via libopencore-amrnb [no] |
| `--disable-libopencore-amrwb` | **【默认禁用】FFmpeg 默认关闭** | enable AMR-WB decoding via libopencore-amrwb [no] |
| `--disable-libopencv` | **【默认禁用】FFmpeg 默认关闭** | enable video filtering via libopencv [no] |
| `--disable-libopenh264` | **【默认禁用】FFmpeg 默认关闭** | enable H.264 encoding via OpenH264 [no] |
| `--disable-libopenjpeg` | **【默认禁用】FFmpeg 默认关闭** | enable JPEG 2000 encoding via OpenJPEG [no] |
| `--disable-libopenmpt` | **【显式禁用】cmake 配置** | enable decoding tracked files via libopenmpt [no] |
| `--disable-libopenvino` | **【默认禁用】FFmpeg 默认关闭** | enable OpenVINO as a DNN module backend for DNN based filters like dnn_processing [no] |
| `--disable-libplacebo` | **【显式禁用】cmake 配置** | enable libplacebo library [no] |
| `--disable-libpulse` | **【默认禁用】FFmpeg 默认关闭** | enable Pulseaudio input via libpulse [no] |
| `--disable-libqrencode` | **【默认禁用】FFmpeg 默认关闭** | enable QR encode generation via libqrencode [no] |
| `--disable-libquirc` | **【默认禁用】FFmpeg 默认关闭** | enable QR decoding via libquirc [no] |
| `--disable-librabbitmq` | **【默认禁用】FFmpeg 默认关闭** | enable RabbitMQ library [no] |
| `--disable-librav1e` | **【默认禁用】FFmpeg 默认关闭** | enable AV1 encoding via rav1e [no] |
| `--disable-librist` | **【默认禁用】FFmpeg 默认关闭** | enable RIST via librist [no] |
| `--disable-librsvg` | **【默认禁用】FFmpeg 默认关闭** | enable SVG rasterization via librsvg [no] |
| `--disable-librtmp` | **【默认禁用】FFmpeg 默认关闭** | enable RTMP[E] support via librtmp [no] |
| `--disable-librubberband` | **【默认禁用】FFmpeg 默认关闭** | enable rubberband needed for rubberband filter [no] |
| `--disable-libshine` | **【默认禁用】FFmpeg 默认关闭** | enable fixed-point MP3 encoding via libshine [no] |
| `--disable-libsmbclient` | **【默认禁用】FFmpeg 默认关闭** | enable Samba protocol via libsmbclient [no] |
| `--disable-libsnappy` | **【默认禁用】FFmpeg 默认关闭** | enable Snappy compression, needed for hap encoding [no] |
| `--disable-libspeex` | **【显式禁用】cmake 配置** | enable Speex de/encoding via libspeex [no] |
| `--disable-libsrt` | **【显式禁用】cmake 配置** | enable Haivision SRT protocol via libsrt [no] |
| `--disable-libssh` | **【显式禁用】cmake 配置** | enable SFTP protocol via libssh [no] |
| `--disable-libsvtav1` | **【显式禁用】cmake 配置** | enable AV1 encoding via SVT [no] |
| `--disable-libsvtjpegxs` | **【默认禁用】FFmpeg 默认关闭** | enable JPEGXS encoding/decoding via SVT [no]（JPEG XS 编解码；`libsvtjpegxs` 解码器/编码器与 `image_jpegxs_pipe` 解复用器的解码侧依赖） |
| `--disable-libtensorflow` | **【默认禁用】FFmpeg 默认关闭** | enable TensorFlow as a DNN module backend for DNN based filters like sr [no] |
| `--disable-libtesseract` | **【默认禁用】FFmpeg 默认关闭** | enable Tesseract, needed for ocr filter [no] |
| `--disable-libtheora` | **【默认禁用】FFmpeg 默认关闭** | enable Theora encoding via libtheora [no] |
| `--disable-libtls` | **【默认禁用】FFmpeg 默认关闭** | enable LibreSSL (via libtls), needed for https support if openssl, gnutls or mbedtls is not used [no] |
| `--disable-libtorch` | **【默认禁用】FFmpeg 默认关闭** | enable Torch as one DNN backend [no] |
| `--disable-libtwolame` | **【默认禁用】FFmpeg 默认关闭** | enable MP2 encoding via libtwolame [no] |
| `--disable-libv4l2` | **【默认禁用】FFmpeg 默认关闭** | enable libv4l2/v4l-utils [no] |
| `--disable-libvidstab` | **【默认禁用】FFmpeg 默认关闭** | enable video stabilization using vid.stab [no] |
| `--disable-libvmaf` | **【默认禁用】FFmpeg 默认关闭** | enable vmaf filter via libvmaf [no] |
| `--disable-libvo-amrwbenc` | **【默认禁用】FFmpeg 默认关闭** | enable AMR-WB encoding via libvo-amrwbenc [no] |
| `--disable-libvvenc` | **【默认禁用】FFmpeg 默认关闭** | enable H.266/VVC encoding via vvenc [no] |
| `--disable-libx264` | **【显式禁用】cmake 配置** | enable H.264 encoding via x264 [no] |
| `--disable-libx265` | **【显式禁用】cmake 配置** | enable HEVC encoding via x265 [no] |
| `--disable-libxavs` | **【默认禁用】FFmpeg 默认关闭** | enable AVS encoding via xavs [no] |
| `--disable-libxavs2` | **【默认禁用】FFmpeg 默认关闭** | enable AVS2 encoding via xavs2 [no] |
| `--disable-libxcb` | **【默认禁用】FFmpeg 默认关闭** | enable X11 grabbing using XCB [autodetect] |
| `--disable-libxcb-shape` | **【默认禁用】FFmpeg 默认关闭** | enable X11 grabbing shape rendering [autodetect] |
| `--disable-libxcb-shm` | **【默认禁用】FFmpeg 默认关闭** | enable X11 grabbing shm communication [autodetect] |
| `--disable-libxcb-xfixes` | **【默认禁用】FFmpeg 默认关闭** | enable X11 grabbing mouse rendering [autodetect] |
| `--disable-libxevd` | **【默认禁用】FFmpeg 默认关闭** | enable EVC decoding via libxevd [no] |
| `--disable-libxevdb` | **【默认禁用】FFmpeg 默认关闭** | enable EVC decoding via libxevd (Base profile) [no]（MPEG-5 EVC Base profile 解码；与 `--disable-libxevd` 并存，二者均未启用） |
| `--disable-libxeve` | **【默认禁用】FFmpeg 默认关闭** | enable EVC encoding via libxeve [no] |
| `--disable-libxeveb` | **【默认禁用】FFmpeg 默认关闭** | enable EVC encoding via libxeve (Base profile) [no]（MPEG-5 EVC Base profile 编码；与 `--disable-libxeve` 并存，二者均未启用） |
| `--disable-libxvid` | **【显式禁用】cmake 配置** | enable Xvid encoding via xvidcore, native MPEG-4/Xvid encoder exists [no] |
| `--disable-libzmq` | **【默认禁用】FFmpeg 默认关闭** | enable message passing via libzmq [no] |
| `--disable-libzvbi` | **【显式禁用】cmake 配置** | enable teletext support via libzvbi [no] |
| `--disable-lv2` | **【默认禁用】FFmpeg 默认关闭** | enable LV2 audio filtering [no] |
| `--disable-mbedtls` | **【默认禁用】FFmpeg 默认关闭** | enable mbedTLS, needed for https support if openssl, gnutls or libtls is not used [no] |
| `--disable-mediacodec` | **【默认禁用】FFmpeg 默认关闭** | enable Android MediaCodec support [no] |
| `--disable-mediafoundation` | **【默认禁用】FFmpeg 默认关闭** | enable encoding via MediaFoundation [auto] |
| `--disable-metal` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable Apple Metal framework [autodetect] |
| `--disable-ohcodec` | **【默认禁用】FFmpeg 默认关闭** | enable OpenHarmony Codec support [no] |
| `--disable-openal` | **【显式禁用】cmake 配置** | enable OpenAL 1.1 capture support [no] |
| `--disable-opencl` | **【默认禁用】FFmpeg 默认关闭** | enable OpenCL processing [no] |
| `--disable-opengl` | **【显式禁用】cmake 配置** | enable OpenGL rendering [no] |
| `--disable-pocketsphinx` | **【默认禁用】FFmpeg 默认关闭** | enable PocketSphinx, needed for asr filter [no] |
| `--disable-schannel` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable SChannel SSP, needed for TLS support on Windows if openssl and gnutls are not used [autodetect] |
| `--disable-sdl2` | **【显式禁用】cmake 配置** | disable sdl2 [autodetect] |
| `--disable-securetransport` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable Secure Transport, needed for TLS support on OSX if openssl and gnutls are not used [autodetect] |
| `--disable-sndio` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable sndio support [autodetect] |
| `--disable-vapoursynth` | **【显式禁用】cmake 配置** | enable VapourSynth demuxer [no] |
| `--disable-whisper` | **【显式禁用】cmake 配置** | enable whisper filter [no] |
| `--disable-xlib` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable xlib [autodetect] |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 3 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-libcelt` | **【已过时】n9.0.1 已移除** | enable CELT decoding via libcelt [no]（CELT 已被 Opus 吸收，独立的 libcelt 支持废弃；继续传递会以 “Unknown option” 终止 configure，建议从配置中删除） |
| `--disable-libglslang` | **【已过时】n9.0.1 已移除** | enable GLSL->SPIRV compilation via libglslang [no]（着色器编译统一到 glslc/SPIR-V 工具链；继续传递会以 “Unknown option” 终止 configure） |
| `--disable-libshaderc` | **【已过时】n9.0.1 已移除** | enable GLSL->SPIRV compilation via libshaderc [no]（由 `--glslc`/`--glslcflags` 离线编译参数取代；继续传递会以 “Unknown option” 终止 configure） |

---

## 2.8 硬件加速功能 (Hardware Acceleration Features)

CUDA、CUVID、D3D11/12VA、AMF、QSV/VPL 等硬解与硬件编码接口

- **启用参数数**：`10` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`13` 项 ｜ **已过时的禁用参数数**：`3` 项

### 启用参数列表 (Enabled - 共 10 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-amf` | **【显式启用】cmake 配置** | disable AMF video encoding code [autodetect] |
| `--enable-cuda` | **【显式启用】cmake 配置** | disable CUDA support [autodetect]（`HWACCEL_AUTODETECT_LIBRARY_LIST` 成员，本构建显式启用，供 CUDA / ffnvcodec 链路使用） |
| `--enable-cuda-llvm` | **【显式启用】cmake 配置** | disable CUDA compilation using clang [autodetect] |
| `--enable-cuvid` | **【显式启用】cmake 配置** | disable Nvidia CUVID support [autodetect] |
| `--enable-d3d11va` | **【显式启用】cmake 配置** | disable Microsoft Direct3D 11 video acceleration code [autodetect] |
| `--enable-d3d12va` | **【显式启用】cmake 配置** | disable Microsoft Direct3D 12 video acceleration code [autodetect] |
| `--enable-ffnvcodec` | **【显式启用】cmake 配置** | disable dynamically linked Nvidia code [autodetect] |
| `--enable-libvpl` | **【显式启用】cmake 配置** | enable Intel oneVPL code via libvpl if libmfx is not used [no] |
| `--enable-nvdec` | **【显式启用】cmake 配置** | disable Nvidia video decoding acceleration (via hwaccel) [autodetect] |
| `--enable-nvenc` | **【显式启用】cmake 配置** | disable Nvidia video encoding code [autodetect] |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 13 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-audiotoolbox` | **【显式禁用】cmake 配置** | disable Apple AudioToolbox code [autodetect] |
| `--disable-cuda-nvcc` | **【默认禁用】FFmpeg 默认关闭** | enable Nvidia CUDA compiler [no] |
| `--disable-dxva2` | **【显式禁用】cmake 配置** | disable Microsoft DirectX 9 video acceleration code [autodetect] |
| `--disable-libdrm` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable DRM code (Linux) [autodetect] |
| `--disable-libmfx` | **【显式禁用】cmake 配置** | enable Intel MediaSDK (AKA Quick Sync Video) code via libmfx [no] |
| `--disable-mmal` | **【默认禁用】FFmpeg 默认关闭** | enable Broadcom Multi-Media Abstraction Layer (Raspberry Pi) via MMAL [no] |
| `--disable-rkmpp` | **【默认禁用】FFmpeg 默认关闭** | enable Rockchip Media Process Platform code [no] |
| `--disable-v4l2-m2m` | **【默认禁用】autodetect (MinGW 未提供/非本平台)** | disable V4L2 mem2mem code [autodetect] |
| `--disable-vaapi` | **【显式禁用】cmake 配置** | disable Video Acceleration API (mainly Unix/Intel) code [autodetect] |
| `--disable-vdpau` | **【显式禁用】cmake 配置** | disable Nvidia Video Decode and Presentation API for Unix code [autodetect] |
| `--disable-videotoolbox` | **【显式禁用】cmake 配置** | disable VideoToolbox code [autodetect] |
| `--disable-vulkan` | **【显式禁用】cmake 配置** | disable Vulkan code [autodetect] |
| `--disable-vulkan-static` | **【显式禁用】cmake 配置** | statically link to libvulkan [no] |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 3 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-libnpp` | **【已过时】n9.0.1 已移除** | enable Nvidia Performance Primitives-based code [no]（NPP 系滤镜 `scale_npp`/`sharpen_npp`/`transpose_npp`/`scale2ref_npp` 一并移除；该选项名仍被识别但只打印 “libnpp has been removed and enabling it does nothing.”，不再产生任何作用） |
| `--disable-omx` | **【已过时】n9.0.1 已移除** | enable OpenMAX IL code [no]（OpenMAX IL 抽象层废弃，`h264_omx`/`mpeg4_omx` 编码器一并移除；继续传递会以 “Unknown option” 终止 configure） |
| `--disable-omx-rpi` | **【已过时】n9.0.1 已移除** | enable OpenMAX IL code for Raspberry Pi [no]（树莓派专用 OpenMAX IL 实现废弃；继续传递会以 “Unknown option” 终止 configure） |

---

## 2.9 架构与指令集优化选项 (Optimization Options)

内联汇编、LTO、运行时CPU检测及各CPU指令集优化

- **启用参数数**：`48` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`0` 项 ｜ **已过时的禁用参数数**：`2` 项

### 启用参数列表 (Enabled - 共 48 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-aesni` | **【默认启用】FFmpeg 默认开启** | disable AESNI optimizations |
| `--enable-altivec` | **【默认启用】FFmpeg 默认开启** | disable AltiVec optimizations |
| `--enable-arm-crc` | **【默认启用】FFmpeg 默认开启** | `--disable-arm-crc` 未配置 → disable ARM/AArch64 CRC optimizations（属于 `ARCH_EXT_LIST_ARM`；本构建目标为 x86_64，不适用） |
| `--enable-armv5te` | **【默认启用】FFmpeg 默认开启** | disable armv5te optimizations |
| `--enable-armv6` | **【默认启用】FFmpeg 默认开启** | disable armv6 optimizations |
| `--enable-armv6t2` | **【默认启用】FFmpeg 默认开启** | disable armv6t2 optimizations |
| `--enable-asm` | **【显式启用】cmake 配置** | disable all assembly optimizations |
| `--enable-avx` | **【默认启用】FFmpeg 默认开启** | disable AVX optimizations |
| `--enable-avx2` | **【默认启用】FFmpeg 默认开启** | disable AVX2 optimizations |
| `--enable-avx512` | **【默认启用】FFmpeg 默认开启** | disable AVX-512 optimizations |
| `--enable-avx512icl` | **【默认启用】FFmpeg 默认开启** | disable AVX-512ICL optimizations |
| `--enable-clmul` | **【默认启用】FFmpeg 默认开启** | `--disable-clmul` 未配置 → disable CLMUL optimizations（属于 `ARCH_EXT_LIST_X86_SIMD`：x86 CLMUL/PCLMULQDQ 无进位乘法优化，本构建目标 x86_64 生效） |
| `--enable-dotprod` | **【默认启用】FFmpeg 默认开启** | disable DOTPROD optimizations |
| `--enable-eor3` | **【默认启用】FFmpeg 默认开启** | `--disable-eor3` 未配置 → disable EOR3 optimizations（ARMv8.2 SHA3 三输入异或；`ARCH_EXT_LIST_ARM`，x86_64 不适用） |
| `--enable-fast-unaligned` | **【默认启用】FFmpeg 默认开启** | consider unaligned accesses slow |
| `--enable-fma3` | **【默认启用】FFmpeg 默认开启** | disable FMA3 optimizations |
| `--enable-fma4` | **【默认启用】FFmpeg 默认开启** | disable FMA4 optimizations |
| `--enable-i8mm` | **【默认启用】FFmpeg 默认开启** | disable I8MM optimizations |
| `--enable-inline-asm` | **【显式启用】cmake 配置** | disable use of inline assembly |
| `--enable-lasx` | **【默认启用】FFmpeg 默认开启** | disable Loongson LASX optimizations |
| `--enable-lsx` | **【默认启用】FFmpeg 默认开启** | disable Loongson LSX optimizations |
| `--enable-mipsdsp` | **【默认启用】FFmpeg 默认开启** | disable MIPS DSP ASE R1 optimizations |
| `--enable-mipsdspr2` | **【默认启用】FFmpeg 默认开启** | disable MIPS DSP ASE R2 optimizations |
| `--enable-mipsfpu` | **【默认启用】FFmpeg 默认开启** | disable floating point MIPS optimizations |
| `--enable-mmi` | **【默认启用】FFmpeg 默认开启** | disable Loongson MMI optimizations |
| `--enable-mmx` | **【默认启用】FFmpeg 默认开启** | disable MMX optimizations |
| `--enable-mmxext` | **【默认启用】FFmpeg 默认开启** | disable MMXEXT optimizations |
| `--enable-msa` | **【默认启用】FFmpeg 默认开启** | disable MSA optimizations |
| `--enable-neon` | **【默认启用】FFmpeg 默认开启** | disable NEON optimizations |
| `--enable-pmull` | **【默认启用】FFmpeg 默认开启** | `--disable-pmull` 未配置 → disable PMULL optimizations（ARM64 多项式乘法长指令；`ARCH_EXT_LIST_ARM`，x86_64 不适用） |
| `--enable-power8` | **【默认启用】FFmpeg 默认开启** | disable POWER8 optimizations |
| `--enable-rvv` | **【默认启用】FFmpeg 默认开启** | disable RISC-V Vector optimizations |
| `--enable-simd128` | **【默认启用】FFmpeg 默认开启** | disable WebAssembly simd128 optimizations |
| `--enable-sme` | **【默认启用】FFmpeg 默认开启** | `--disable-sme` 未配置 → disable SME optimizations（ARM 可伸缩矩阵扩展；`ARCH_EXT_LIST_ARM`，x86_64 不适用） |
| `--enable-sme-i16i64` | **【默认启用】FFmpeg 默认开启** | `--disable-sme-i16i64` 未配置 → disable SME-I16I64 optimizations（ARM SME 16 位整数累加至 64 位；`ARCH_EXT_LIST_ARM`，x86_64 不适用） |
| `--enable-sme2` | **【默认启用】FFmpeg 默认开启** | `--disable-sme2` 未配置 → disable SME2 optimizations（ARM 第二代可伸缩矩阵扩展；`ARCH_EXT_LIST_ARM`，x86_64 不适用） |
| `--enable-sse` | **【默认启用】FFmpeg 默认开启** | disable SSE optimizations |
| `--enable-sse2` | **【默认启用】FFmpeg 默认开启** | disable SSE2 optimizations |
| `--enable-sse3` | **【默认启用】FFmpeg 默认开启** | disable SSE3 optimizations |
| `--enable-sse4` | **【默认启用】FFmpeg 默认开启** | disable SSE4 optimizations |
| `--enable-sse42` | **【默认启用】FFmpeg 默认开启** | disable SSE4.2 optimizations |
| `--enable-ssse3` | **【默认启用】FFmpeg 默认开启** | disable SSSE3 optimizations |
| `--enable-sve` | **【默认启用】FFmpeg 默认开启** | disable SVE optimizations |
| `--enable-sve2` | **【默认启用】FFmpeg 默认开启** | disable SVE2 optimizations |
| `--enable-vfp` | **【默认启用】FFmpeg 默认开启** | disable VFP optimizations |
| `--enable-vsx` | **【默认启用】FFmpeg 默认开启** | disable VSX optimizations |
| `--enable-x86asm` | **【默认启用】FFmpeg 默认开启** | disable use of standalone x86 assembly |
| `--enable-xop` | **【默认启用】FFmpeg 默认开启** | disable XOP optimizations |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无 —— 原有失效条目 `--enable-amd3dnow`、`--enable-amd3dnowext` 已归入下方"已过时的禁用"）*

### 禁用参数列表 (Disabled - 共 0 项)

*（无参数）*

### 已过时的禁用参数列表 (Obsolete Disabled - 共 2 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-amd3dnow` | **【已过时】n9.0.1 已移除** | disable 3DNow! optimizations（3DNow! 指令集早已被 SSE/AVX 取代；已从 `--help` 与配置汇总输出中删除，内部仅残留同名占位标记，写入配置不再产生任何作用） |
| `--enable-amd3dnowext` | **【已过时】n9.0.1 已移除** | disable 3DNow! extended optimizations（3DNow! 扩展指令集，同 `amd3dnow` 一并废弃，不再产生作用） |

---

## 2.10 开发与调试测试选项 (Developer & Debugging Options)

调试符号、寄存器破坏测试、版本追踪及性能监测工具

- **启用参数数**：`7` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`13` 项 ｜ **已过时的禁用参数数**：`1` 项
- **带值配置参数数**：`6` 项

### 启用参数列表 (Enabled - 共 7 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-disable-random` | **【默认启用】FFmpeg 默认开启** | component groups. LIST is a comma-separated list of NAME[:PROB] entries where NAME is a component (group) and PROB the probability associated with NAME (default 0.5). |
| `--enable-large-tests` | **【默认启用】FFmpeg 默认开启** | disable tests that use a large amount of memory |
| `--enable-optimizations` | **【显式启用】cmake 配置** | disable compiler optimizations |
| `--enable-resource-compression` | **【默认启用】FFmpeg 默认开启** | don't compress resources even when possible |
| `--enable-shader-compression` | **【默认启用】FFmpeg 默认开启** | `--disable-shader-compression` 未配置 → don't compress shader code even when possible（压缩策略的统一开关；本构建已 `--enable-zlib` 且构建机具备 `gzip`，满足其 `zlib_gzip` 依赖，保持启用） |
| `--enable-stripping` | **【显式启用】cmake 配置** | disable stripping of executables and shared libraries |
| `--enable-valgrind-backtrace` | **【默认启用】FFmpeg 默认开启** | do not print a backtrace under Valgrind (only applies to --disable-optimizations builds) |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无 —— 原有失效条目 `--enable-ptx-compression` 已归入下方"已过时的禁用"）*

### 禁用参数列表 (Disabled - 共 13 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-debug` | **【显式禁用】cmake 配置** | disable debugging symbols |
| `--disable-enable-debug` | **【默认禁用】FFmpeg 默认关闭** | set the debug level [] |
| `--disable-enable-random` | **【默认禁用】FFmpeg 默认关闭** | randomly enable/disable specific components or |
| `--disable-extra-warnings` | **【默认禁用】FFmpeg 默认关闭** | enable more compiler warnings |
| `--disable-ftrapv` | **【默认禁用】FFmpeg 默认关闭** | Trap arithmetic overflows |
| `--disable-linux-perf` | **【显式禁用】cmake 配置** | enable Linux Performance Monitor API |
| `--disable-macos-kperf` | **【默认禁用】FFmpeg 默认关闭** | enable macOS kperf (private) API |
| `--disable-memory-poisoning` | **【默认禁用】FFmpeg 默认关闭** | fill heap uninitialized allocated space with arbitrary data |
| `--disable-neon-clobber-test` | **【显式禁用】cmake 配置** | check NEON registers for clobbering (should be used only for debugging purposes) |
| `--disable-ossfuzz` | **【默认禁用】FFmpeg 默认关闭** | Enable building fuzzer tool |
| `--disable-random` | **【默认禁用】FFmpeg 默认关闭** | randomly enable/disable components |
| `--disable-version-tracking` | **【显式禁用】cmake 配置** | don't include the git/release version in the build |
| `--disable-xmm-clobber-test` | **【显式禁用】cmake 配置** | check XMM registers for clobbering (Win64-only; should be used only for debugging purposes) |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 1 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-ptx-compression` | **【已过时】n9.0.1 已移除** | don't compress CUDA PTX code even when possible（压缩策略统一为 `--disable-shader-compression`；继续传递旧选项会以 “Unknown option” 终止 configure） |

### 工具链与环境配置值列表 (Configured Values - 共 6 项)

| 参数选项 | 配置值 / 状态 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--assert-level=level` | *未配置 (采用默认)* | 0(default), 1 or 2, amount of assertion testing, 2 causes a slowdown at runtime. |
| `--ignore-tests=TESTS` | *未配置 (采用默认)* | comma-separated list (without "fate-" prefix in the name) of tests whose result is ignored |
| `--libfuzzer=PATH` | *未配置 (采用默认)* | path to libfuzzer |
| `--random-seed=VALUE` | *未配置 (采用默认)* | seed value for --enable/disable-random |
| `--samples=PATH` | *未配置 (采用默认)* | location of test samples for FATE, if not set use $FATE_SAMPLES at make invocation time. |
| `--valgrind=VALGRIND` | *未配置 (采用默认)* | run "make fate" tests through valgrind to detect memory leaks and errors, using the specified valgrind binary. Cannot be combined with --target-exec |

---

## 2.11 高级内核选项 (Advanced Options)

自定义内存分配器、安全比特流读取器等底层调节

- **启用参数数**：`2` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`0` 项 ｜ **已过时的禁用参数数**：`0` 项
- **带值配置参数数**：`3` 项

### 启用参数列表 (Enabled - 共 2 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-hardcoded-tables` | **【显式启用】cmake 配置** | use hardcoded tables instead of runtime generation |
| `--enable-symver` | **【默认启用】FFmpeg 默认开启** | disable symbol versioning |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 0 项)

*（无参数）*

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

### 工具链与环境配置值列表 (Configured Values - 共 3 项)

| 参数选项 | 配置值 / 状态 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--custom-allocator=NAME` | *未配置 (采用默认)* | use a supported custom allocator |
| `--malloc-prefix=PREFIX` | *未配置 (采用默认)* | prefix malloc and related names with PREFIX |
| `--sws-max-filter-size=N` | *未配置 (采用默认)* | the max filter size swscale uses [256] |

---

## 2.12 构建工具链与编译选项 (Toolchain Options)

交叉编译工具链（Clang/LLVM）、C/C++语言标准及编译旗标

- **启用参数数**：`4` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`1` 项 ｜ **已过时的禁用参数数**：`0` 项
- **带值配置参数数**：`55` 项

### 启用参数列表 (Enabled - 共 4 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-cross-compile` | **【显式启用】cmake 配置** | assume a cross-compiler is used |
| `--enable-lto=full` | **【显式启用】cmake 配置** | use link-time optimization [no]（带可选参数形式；本构建使用 `--enable-lto=full`，即全量 LTO） |
| `--enable-pic` | **【显式启用】cmake 配置** | build position-independent code |
| `--enable-response-files` | **【默认启用】FFmpeg 默认开启** | Don't pass the list of objects to linker in a file [autodetect] |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 1 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-thumb` | **【默认禁用】FFmpeg 默认关闭** | compile for Thumb instruction set |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

### 工具链与环境配置值列表 (Configured Values - 共 55 项)

| 参数选项 | 配置值 / 状态 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--ar=AR` | **已配置**：`${TARGET_ARCH}-llvm-ar` | use archive tool AR [ar] |
| `--arch=ARCH` | **已配置**：`${TARGET_CPU}` | select architecture [] |
| `--as=AS` | *未配置 (采用默认)* | use assembler AS [] |
| `--build-suffix=SUFFIX` | *未配置 (采用默认)* | library name suffix [] |
| `--cc=CC` | **已配置**：`${TARGET_ARCH}-clang` | use C compiler CC [gcc] |
| `--cpu=CPU` | *未配置 (采用默认)* | select the minimum required CPU (affects instruction selection, may crash on older CPUs) |
| `--cross-prefix=PREFIX` | **已配置**：`${TARGET_ARCH}-` | use PREFIX for compilation tools [] |
| `--cxx=CXX` | **已配置**：`${TARGET_ARCH}-clang++` | use C compiler CXX [g++] |
| `--dep-cc=DEPCC` | *未配置 (采用默认)* | use dependency generator DEPCC [gcc] |
| `--doxygen=DOXYGEN` | *未配置 (采用默认)* | use DOXYGEN to generate API doc [doxygen] |
| `--env="ENV=override"` | *未配置 (采用默认)* | override the environment variables |
| `--extra-cflags=ECFLAGS` | **已配置**：`${CFLAGS} -Wno-error=int-conversion -ffunction-sections -fdata-sections` | add ECFLAGS to CFLAGS [] |
| `--extra-cxxflags=ECFLAGS` | **已配置**：`${CXXFLAGS} -ffunction-sections -fdata-sections` | add ECFLAGS to CXXFLAGS [] |
| `--extra-ldexeflags=ELDFLAGS` | *未配置 (采用默认)* | add ELDFLAGS to LDEXEFLAGS [] |
| `--extra-ldflags=ELDFLAGS` | **已配置**：`${LDFLAGS} ` | add ELDFLAGS to LDFLAGS [] |
| `--extra-ldsoflags=ELDFLAGS` | *未配置 (采用默认)* | add ELDFLAGS to LDSOFLAGS [] |
| `--extra-libs=ELIBS` | **已配置**：`${ffmpeg_extra_libs} -lm` | add ELIBS [] |
| `--extra-objcflags=FLAGS` | *未配置 (采用默认)* | add FLAGS to OBJCFLAGS [] |
| `--extra-version=STRING` | *未配置 (采用默认)* | version string suffix [] |
| `--glslc=GLSLC` | *未配置 (采用默认)* | use GLSL compiler GLSLC [glslc]（GLSL→SPIR-V 离线编译工具，供 Vulkan 滤镜/着色器使用） |
| `--glslcflags=GLSLCFLAGS` | *未配置 (采用默认)* | extra glslc flags []（传递给 glslc 的附加参数） |
| `--host-cc=HOSTCC` | *未配置 (采用默认)* | use host C compiler HOSTCC |
| `--host-cflags=HCFLAGS` | *未配置 (采用默认)* | use HCFLAGS when compiling for host |
| `--host-cppflags=HCPPFLAGS` | *未配置 (采用默认)* | use HCPPFLAGS when compiling for host |
| `--host-extralibs=HLIBS` | *未配置 (采用默认)* | use libs HLIBS when linking for host |
| `--host-ld=HOSTLD` | *未配置 (采用默认)* | use host linker HOSTLD |
| `--host-ldflags=HLDFLAGS` | *未配置 (采用默认)* | use HLDFLAGS when linking for host |
| `--host-os=OS` | *未配置 (采用默认)* | compiler host OS [] |
| `--ld=LD` | *未配置 (采用默认)* | use linker LD [] |
| `--ln_s=LN_S` | *未配置 (采用默认)* | use symbolic link tool LN_S [ln -s -f] |
| `--makeinfo=MAKEINFO` | *未配置 (采用默认)* | use MAKEINFO to generate documentation [makeinfo]（Texinfo 手册生成工具；本构建 `--disable-doc`，不涉及） |
| `--metalcc=METALCC` | *未配置 (采用默认)* | use metal compiler METALCC [xcrun -sdk macosx metal] |
| `--metallib=METALLIB` | *未配置 (采用默认)* | use metal linker METALLIB [xcrun -sdk macosx metallib] |
| `--nm=NM` | **已配置**：`${TARGET_ARCH}-nm` | use nm tool NM [nm -g] |
| `--nvcc=NVCC` | *未配置 (采用默认)* | use Nvidia CUDA compiler NVCC or clang [] |
| `--nvccflags=NVCCFLAGS` | *未配置 (采用默认)* | override nvcc flags [] |
| `--objcc=OCC` | *未配置 (采用默认)* | use ObjC compiler OCC [gcc] |
| `--optflags=OPTFLAGS` | *未配置 (采用默认)* | override optimization-related compiler flags |
| `--pkg-config-flags=FLAGS` | **已配置**：`--static` | pass additional flags to pkgconf [] |
| `--pkg-config=PKGCONFIG` | *未配置 (采用默认)* | use pkg-config tool PKGCONFIG [pkg-config] |
| `--progs-suffix=SUFFIX` | *未配置 (采用默认)* | program name suffix [] |
| `--ranlib=RANLIB` | **已配置**：`${TARGET_ARCH}-llvm-ranlib` | use ranlib RANLIB [ranlib] |
| `--stdc=STDC` | **已配置**：`c23` | use C standard STDC [c17] |
| `--stdcxx=STDCXX` | **已配置**：`c++23` | use C standard STDCXX [c++11] |
| `--strip=STRIP` | **已配置**：`${TARGET_ARCH}-strip` | use strip tool STRIP [strip] |
| `--sysinclude=PATH` | *未配置 (采用默认)* | location of cross-build system headers |
| `--sysroot=PATH` | *未配置 (采用默认)* | root of cross-build tree |
| `--target-exec=CMD` | *未配置 (采用默认)* | command to run executables on target |
| `--target-os=OS` | **已配置**：`mingw32` | compiler targets OS [] |
| `--target-path=DIR` | *未配置 (采用默认)* | path to view of build directory on target |
| `--target-samples=DIR` | *未配置 (采用默认)* | path to samples directory on target |
| `--tempprefix=PATH` | *未配置 (采用默认)* | force fixed dir/prefix instead of mktemp for checks |
| `--toolchain=NAME` | *未配置 (采用默认)* | set tool defaults according to NAME (<tool>[-sanitizer[-...]], e.g. clang-asan-ubsan tools: gcc, clang, msvc, icl, gcov, llvm-cov, valgrind-memcheck, valgrind-massif, hardened sanitizers: asan, fuzz, lsan, msan, tsan, ubsan) |
| `--windres=WINDRES` | *未配置 (采用默认)* | use windows resource compiler WINDRES [windres] |
| `--x86asmexe=EXE` | *未配置 (采用默认)* | use nasm-compatible assembler EXE [nasm] |

---

## 2.13 标准安装路径与环境选项 (Standard Options)

安装前缀、库路径、头文件路径及日志开关

- **启用参数数**：`1` 项 ｜ **已过时的启用参数数**：`0` 项
- **禁用参数数**：`4` 项 ｜ **已过时的禁用参数数**：`0` 项
- **带值配置参数数**：`11` 项

### 启用参数列表 (Enabled - 共 1 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--enable-logging` | **【默认启用】FFmpeg 默认开启** | do not log configure debug information |

### 已过时的启用参数列表 (Obsolete Enabled - 共 0 项)

*（无参数）*

### 禁用参数列表 (Disabled - 共 4 项)

| 命令行参数 | 状态判定 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--disable-rpath` | **【默认禁用】FFmpeg 默认关闭** | use rpath to allow installing libraries in paths not part of the dynamic linker search path use rpath when linking programs (USE WITH CARE) |
| `--fatal-warnings` | **【未配置】** | fail if any configure warning is generated |
| `--help` | **【未配置】** | print this message |
| `--quiet` | **【未配置】** | Suppress showing informative output |

### 已过时的禁用参数列表 (Obsolete Disabled - 共 0 项)

*（无参数）*

### 工具链与环境配置值列表 (Configured Values - 共 11 项)

| 参数选项 | 配置值 / 状态 | 说明及默认行为 |
| :--- | :--- | :--- |
| `--bindir=DIR` | *未配置 (采用默认)* | install binaries in DIR [PREFIX/bin] |
| `--datadir=DIR` | *未配置 (采用默认)* | install data files in DIR [PREFIX/share/ffmpeg] |
| `--docdir=DIR` | *未配置 (采用默认)* | install documentation in DIR [PREFIX/share/doc/ffmpeg] |
| `--incdir=DIR` | *未配置 (采用默认)* | install includes in DIR [PREFIX/include] |
| `--install-name-dir=DIR` | *未配置 (采用默认)* | Darwin directory name for installed targets |
| `--libdir=DIR` | *未配置 (采用默认)* | install libs in DIR [PREFIX/lib] |
| `--logfile=FILE` | *未配置 (采用默认)* | log tests and output to FILE [ffbuild/config.log] |
| `--mandir=DIR` | *未配置 (采用默认)* | install man page in DIR [PREFIX/share/man] |
| `--pkgconfigdir=DIR` | *未配置 (采用默认)* | install pkg-config files in DIR [LIBDIR/pkgconfig] |
| `--prefix=PREFIX` | **已配置**：`${MINGW_INSTALL_PREFIX}` | install in PREFIX [/usr/local] |
| `--shlibdir=DIR` | *未配置 (采用默认)* | install shared libs in DIR [LIBDIR] |

---


---

# 附录 A：已执行的配置清理与可选启用项

## A.1 已清理的失效条目（本次执行）

`packages/ffmpeg.cmake` 中原有的 3 个已失效条目已删除，此前的 configure 告警（`warn "Option ... did not match anything"`）随之消失：

| 所在参数 | 已删除条目 | 原因 | 清理后状态 |
| :--- | :--- | :--- | :--- |
| `--enable-decoder=` | `sonic` | FFmpeg n9.0.1 已移除 Sonic 编解码 | 归入 1.6 节"已过时的禁用"；`sonic` 同族的 `sonic_ls` 编码器亦已移除 |
| `--enable-protocol=` | `hls` | FFmpeg n9.0.1 已移除旧版 HLS 协议处理器 | 归入 1.11 节"已过时的禁用"；HLS 播放由 `hls` 解复用器 + `http/https/httpproxy/tls/crypto/cache` 协议栈承担 |
| `--enable-demuxer=` | `afx` | 上游从未提供 `afx` 解复用器（n8.0.2 时即已失效），属历史笔误 | 该名称本就不存在于组件清单，无需在文档中记录；如原意是 AFC 音频格式，请重新加入 `afc` |

## A.2 全局参数

当前 `ffmpeg.cmake` **未使用** n9.0.1 已移除的任何全局参数（`--disable-omx`、`--disable-omx-rpi`、`--enable-libcelt`、`--enable-libglslang`、`--enable-libnpp`、`--enable-libshaderc`、`--disable-ptx-compression`、`--disable-amd3dnow`、`--disable-amd3dnowext` 均未出现），因此无需清理，升级不存在 "Unknown option" 中断风险；这些参数已作为"已过时的禁用"记录在第二部分各模块中。

## A.3 本次新增并启用的配置

| 能力 | 已加入 `ffmpeg.cmake` 的配置 | 生效位置 |
| :--- | :--- | :--- |
| 动态 WebP 原生播放 | `--enable-decoder=webp_anim` + `--enable-demuxer=webp_anim` | 1.6 解码器启用列表、1.9 解复用器启用列表 |
| Dolby Vision 双层拆分 | `--enable-bsf=dovi_split` | 1.4 比特流滤镜启用列表 |
| D3D12 硬件缩放/反交错/运动估计 | `--enable-filter=scale_d3d12,deinterlace_d3d12,mestimate_d3d12` | 1.10 滤镜启用列表 |

## A.4 仍未启用的候选组件（按需评估）

| 需求场景 | 需要追加的配置 | 依赖前提（未启用原因） |
| :--- | :--- | :--- |
| 矢量图形/水印绘制 | `--enable-filter=drawvg` | **需要 cairo 依赖**，会引入新的外部库，故本次不启用（`drawvg` 保留在 1.10 禁用列表） |
| 局部色彩管理（ACES 等） | `--enable-filter=ocio` + `--enable-libopencolorio` | 需新增 OpenColorIO 依赖包 |
| JPEG XS 编解码 | `--enable-libsvtjpegxs` | 需新增 SVT-JPEG XS 依赖包（`image_jpegxs_pipe` 解复用器已在启用列表，加库后即可解码） |
| MPEG-H 3D Audio 解码 | `--enable-libmpeghdec` | 需新增 libmpeghdec 依赖包 |
| Windows 抓屏 / CUDA 转置 | `--enable-filter=gfxcapture,amf_capture,transpose_cuda` | 依赖已满足，仅需追加白名单；`gfxcapture` 还要求 C++17 与 `IGraphicsCaptureItemInterop` 头文件 |
| Vulkan 系滤镜 | `--enable-vulkan` + `--enable-filter=v360_vulkan,prores_ks_vulkan` 等 | 当前 `--disable-vulkan`/`--disable-vulkan-static` |

---

# 附录 B：数据来源与校验方法

| 项目 | 方法 |
| :--- | :--- |
| 组件清单 (n8.0.2 / n9.0.1) | 分别从上游 tag `n8.0.2`、`n9.0.1` 的 `libavcodec/allcodecs.c`（编解码器）、`libavcodec/parsers.c`（解析器）、`libavcodec/bitstream_filters.c`（比特流滤镜）、`libavformat/allformats.c`（复用/解复用器）、`libavformat/protocols.c`（协议）、`libavfilter/allfilters.c`（滤镜）、`libavdevice/alldevices.c`（输入/输出设备）提取，口径与 configure 内 `find_things_extern` 一致（类型前缀归一化、跳过 `#` 注释行） |
| 参数清单 | 比对两侧 `configure --help` 全量选项：n8.0.2 = 386 项 → n9.0.1 = 397 项（新增 20、移除 9），并逐项核对 configure 源码中的默认值与依赖字段 |
| 组件归属判定 | 按 `ffmpeg.cmake` 实际命令行复现 configure 的匹配逻辑（`--enable-<类型>=列表` 按 shell 通配匹配；解析器为"全开 + 黑名单"），不额外套用依赖剔除结果 |
| 依赖信息 | 取自 n9.0.1 `configure` 的 `*_deps` / `*_select` 声明（如 `lgpl_gpl`、`d3d12va`、`rkmpp`、`libsvtjpegxs`、`mmap stdatomic unistd_h` 等） |
| 配置镜像校验 | 各模块"配置规则"块由脚本从 `packages/ffmpeg.cmake` 直接提取，与文件内容逐项一致（含本次清理与新增的条目） |
| 文档补全 | 原清单遗漏但 `ffmpeg.cmake` 实际使用的 3 个参数已补入对应模块的启用列表：`--enable-hwaccels`（2.6）、`--enable-cuda`（2.8）、`--enable-lto=full`（2.12） |

### 校验结果

- **组件层**：`启用 + 禁用 = 809 + 1411 = 2220` = 支持总数 ✓；`已过时的禁用 = 17` = n8.0.2 → n9.0.1 移除的组件总数 ✓（已过时的启用 0 项 —— 失效条目已清理）。
- **参数层**：开关型参数 `启用 114 + 禁用 162 = 276`，另 `已过时的禁用 9`（与上游 n9.0.1 移除数一致 ✓），带值参数 75 项。
- **n8.0.2 回放**：用同一套脚本在 n8.0.2 组件清单 + 原 `ffmpeg.cmake` 上回放，所得启用/禁用集合与本文件早期版本完全一致（如解码器 411/185、滤镜 43/542、协议 14/41、解析器 55/9 均复现），表明归类口径未变。
- **范围说明**：第二部分覆盖与构建相关的 configure 开关与带值参数；`--list-*` 查询类、动态组件选择类（`--enable-decoder=NAME` 等，已在第一部分展开）以及 `--enable-everything`、`--env=` 等不计入本清单。
