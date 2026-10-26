rm -rf build_x86_64_musicxx/packages/mpv-prefix
rm -rf src_packages_musicxx/mpv
cp -r src_packages_crude_temp/mpv src_packages_musicxx/

cd source/mpv && git switch extend && git pull && git submodule update --init && cd -