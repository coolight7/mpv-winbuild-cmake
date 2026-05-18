script_dir=$(dirname "$0")

/home/coolight/program/media/mpv-winbuild-cmake/clang_root/bin/gendef $script_dir/libmpv-2.dll
/home/coolight/program/media/mpv-winbuild-cmake/clang_root/bin/gendef $script_dir/libmediaxx.dll

objdump -p $script_dir/libmpv-2.dll > $script_dir/libmpv_undef.txt
objdump -p $script_dir/ffmpeg.exe > $script_dir/ffmpeg_undef.txt
objdump -p $script_dir/ffprobe.exe > $script_dir/ffprobe_undef.txt
