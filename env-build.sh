# source env-build.sh
export CFLAGS="-fPIC -ffunction-sections -fdata-sections -O3 -flto"
export CXXFLAGS="-fPIC -ffunction-sections -fdata-sections -O3 -flto"
export LDFLAGS="-Wl,-O3 -Wl,--gc-sections -flto"