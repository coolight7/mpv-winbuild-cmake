rm -rf build_x86_64/x86_64-w64-mingw32/lib/ffmpeg-backup

rm build_x86_64/x86_64-w64-mingw32/bin/avcodec*
rm build_x86_64/x86_64-w64-mingw32/bin/avdevice*
rm build_x86_64/x86_64-w64-mingw32/bin/avfilter*
rm build_x86_64/x86_64-w64-mingw32/bin/avformat*
rm build_x86_64/x86_64-w64-mingw32/bin/avutil*
rm build_x86_64/x86_64-w64-mingw32/bin/swscale*
rm build_x86_64/x86_64-w64-mingw32/bin/swresample*
rm build_x86_64/x86_64-w64-mingw32/bin/ffmpeg*
rm build_x86_64/x86_64-w64-mingw32/bin/ffprobe*

rm build_x86_64/x86_64-w64-mingw32/lib/libavcodec*
rm build_x86_64/x86_64-w64-mingw32/lib/libavdevice*
rm build_x86_64/x86_64-w64-mingw32/lib/libavfilter*
rm build_x86_64/x86_64-w64-mingw32/lib/libavformat*
rm build_x86_64/x86_64-w64-mingw32/lib/libavutil*
rm build_x86_64/x86_64-w64-mingw32/lib/libswscale*
rm build_x86_64/x86_64-w64-mingw32/lib/libswresample*

rm build_x86_64/x86_64-w64-mingw32/lib/avcodec*
rm build_x86_64/x86_64-w64-mingw32/lib/avdevice*
rm build_x86_64/x86_64-w64-mingw32/lib/avfilter*
rm build_x86_64/x86_64-w64-mingw32/lib/avformat*
rm build_x86_64/x86_64-w64-mingw32/lib/avutil*
rm build_x86_64/x86_64-w64-mingw32/lib/swscale*
rm build_x86_64/x86_64-w64-mingw32/lib/swresample*

rm -rf build_x86_64_mpv/packages/ffmpeg-prefix
rm -rf src_packages_mpv/ffmpeg
cp -r src_packages_mpv_temp/ffmpeg src_packages_mpv/