ExternalProject_Add(mediaxx
    DEPENDS
        ffmpeg
        mpv
    UPDATE_COMMAND ""
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/source/mediaxx/src/"
    CONFIGURE_COMMAND ${EXEC} CONF=1 cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        "-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}"
        "-DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}"
        "-DCMAKE_FIND_ROOT_PATH=${MINGW_INSTALL_PREFIX}"
        -DBUILD_SHARED_LIBS=ON
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
        -DSTATIC_LINK_FFMPEG=ON
        -DSTATIC_LINK_LIBMPV=ON
        -DEXPORT_ALL_SYMBOL=OFF
        -DCMAKE_C_FLAGS=' -fvisibility=hidden -ffunction-sections -fdata-sections -flto'
        -DCMAKE_CXX_FLAGS=' -fvisibility=hidden -ffunction-sections -fdata-sections -flto'
        -DCMAKE_SHARED_LINKER_FLAGS=' -Wl,-O3 -Wl,--exclude-all-symbols -Wl,--gc-sections -flto'
    BUILD_COMMAND ${EXEC} LTO_JOB=1 PDB=1 ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

# 如果最终导出符号比指定的多，可以根据符号推断是哪个库，然后 grep "dllexport" ${package-dir} 查找是哪个文件定义的导出声明，去除并重新编译依赖它的库即可

ExternalProject_Add_Step(mediaxx copy-binary
    DEPENDEES install

    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmediaxx.dll           ${CMAKE_SOURCE_DIR}/output/libmediaxx.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmediaxx.dll.a         ${CMAKE_SOURCE_DIR}/output/libmediaxx.dll.a

    COMMAND ${CMAKE_SOURCE_DIR}/clang_root/bin/llvm-strip --strip-all      ${CMAKE_SOURCE_DIR}/output/libmediaxx.dll

    COMMENT "Copying ffmpeg binaries and manual"
)

# cleanup(mediaxx rename-lib-pkgconfig)