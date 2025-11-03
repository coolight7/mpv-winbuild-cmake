cmake_minimum_required(VERSION 3.10)
cmake_policy(SET CMP0097 NEW)

project(mediaxx_ffmpeg_help VERSION 0.0.1 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_definitions(-D__STDC_CONSTANT_MACROS)

find_package(PkgConfig REQUIRED)

set(PKG_CONFIG_FLAGS "--static")

pkg_check_modules(AVCODEC REQUIRED libavcodec)
pkg_check_modules(AVDEVICE REQUIRED libavdevice)
pkg_check_modules(AVFILTER REQUIRED libavfilter)
pkg_check_modules(AVFORMAT REQUIRED libavformat)
pkg_check_modules(AVUTIL REQUIRED libavutil)
pkg_check_modules(SWRESAMPLE REQUIRED libswresample)
pkg_check_modules(SWSCALE REQUIRED libswscale)

add_library(mediaxx SHARED 
    "export.cpp"

    "export.def"
)

target_include_directories(mediaxx PRIVATE 
    ${AVCODEC_INCLUDE_DIRS}
    ${AVDEVICE_INCLUDE_DIRS}
    ${AVFILTER_INCLUDE_DIRS}
    ${AVFORMAT_INCLUDE_DIRS}
    ${AVUTIL_INCLUDE_DIRS}
    ${SWRESAMPLE_INCLUDE_DIRS}
    ${SWSCALE_INCLUDE_DIRS}
)
target_link_directories(mediaxx PRIVATE 
    ${AVCODEC_LIBRARY_DIRS}
    ${AVDEVICE_LIBRARY_DIRS}
    ${AVFILTER_LIBRARY_DIRS}
    ${AVFORMAT_LIBRARY_DIRS}
    ${AVUTIL_LIBRARY_DIRS}
    ${SWRESAMPLE_LIBRARY_DIRS}
    ${SWSCALE_LIBRARY_DIRS}
)
target_link_libraries(mediaxx PUBLIC
    ${AVCODEC_LIBRARIES}
    ${AVDEVICE_LIBRARIES}
    ${AVFILTER_LIBRARIES}
    ${AVFORMAT_LIBRARIES}
    ${AVUTIL_LIBRARIES}
    ${SWRESAMPLE_LIBRARIES}
    ${SWSCALE_LIBRARIES}
    avcodec
    avdevice
    avfilter
    avformat
    avutil
    swresample
    swscale
    m
    shlwapi
    pthread
    cfgmgr32
)

target_compile_options(mediaxx PRIVATE 
    ${AVCODEC_CFLAGS}
    ${AVDEVICE_CFLAGS}
    ${AVFILTER_CFLAGS}
    ${AVFORMAT_CFLAGS}
    ${AVUTIL_CFLAGS}
    ${SWRESAMPLE_CFLAGS}
    ${SWSCALE_CFLAGS}
)

install(TARGETS mediaxx RUNTIME)