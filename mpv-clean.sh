# mpv 的更新方式：先更新备份源 src_packages_crude_temp/mpv（fork 的 extend 分支），
# 再清掉 mpv 的编译产物与工作副本，下次构建会从备份源重新复制
cd src_packages_crude_temp/mpv && git pull && cd ../..
rm -rf build_x86_64_musicxx/packages/mpv-prefix
rm -rf src_packages_musicxx/mpv
cp -r src_packages_crude_temp/mpv src_packages_musicxx/
