ExternalProject_Add(mediaxx
    DEPENDS
        ffmpeg
    UPDATE_COMMAND ""
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../source/mediaxx/src/"
    CONFIGURE_COMMAND ${EXEC} CONF=1 cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        "-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}"
        "-DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}"
        "-DCMAKE_FIND_ROOT_PATH=${MINGW_INSTALL_PREFIX}"
        -DBUILD_SHARED_LIBS=ON
        -DSTATIC_LINK_FFMPEG=ON
        -DEXPORT_ALL_SYMBOL=OFF
    BUILD_COMMAND ${EXEC} LTO_JOB=1 PDB=1 ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

set(BACKUP_RESTORE_LIB ${CMAKE_CURRENT_BINARY_DIR}/mediaxx-prefix/src/backup_restore.sh)
file(WRITE ${BACKUP_RESTORE_LIB}
"#!/bin/bash

lib_path=$1

cd $lib_path

back_path=$lib_path/ffmpeg-backup/

if [[ ! -e $back_path ]]; then
    exit 0
fi

mv avfilter.dll*      $back_path/
mv avutil.dll*        $back_path/
mv avdevice.dll*      $back_path/
mv avcodec.dll*       $back_path/
mv avformat.dll*      $back_path/
mv swresample.dll*    $back_path/
mv swscale.dll*       $back_path/

cp $back_path/avfilter.lib     ./
cp $back_path/avutil.lib       ./
cp $back_path/avdevice.lib     ./
cp $back_path/avcodec.lib      ./
cp $back_path/avformat.lib     ./
cp $back_path/swresample.lib   ./
cp $back_path/swscale.lib      ./

pkgconfig_path=$lib_path/pkgconfig/

reset () {
    if [[ -e $back_path/$1 ]]; then
        rm $pkgconfig_path/$1
        cp $back_path/$1 $pkgconfig_path/
    fi
}

reset 'libavcodec.pc'
reset 'libavformat.pc'
reset 'libavfilter.pc'
reset 'libavutil.pc'
reset 'libavdevice.pc'
reset 'libswresample.pc'
reset 'libswscale.pc'
")

ExternalProject_Add_Step(mediaxx back-lib-pkgconfig
    DEPENDEES update
    COMMAND chmod 755 ${BACKUP_RESTORE_LIB}

    COMMAND ${BACKUP_RESTORE_LIB} ${MINGW_INSTALL_PREFIX}/lib/
    COMMENT "backup  restore"
    LOG 1
)

set(BACKUP_LIB ${CMAKE_CURRENT_BINARY_DIR}/mediaxx-prefix/src/backup.sh)
file(WRITE ${BACKUP_LIB}
"#!/bin/bash

lib_path=$1

cd $lib_path
back_path=$lib_path/ffmpeg-backup/

if [[ -e $back_path ]]; then
    exit 0
fi

mkdir $back_path

mv avfilter.lib     $back_path/
mv avutil.lib       $back_path/
mv avdevice.lib     $back_path/
mv avcodec.lib      $back_path/
mv avformat.lib     $back_path/
mv swresample.lib   $back_path/
mv swscale.lib      $back_path/

pkgconfig_path=$lib_path/pkgconfig/

reset () {
    cp $pkgconfig_path/$1 $back_path/
    sed -i '/^Libs: / s/^Libs:.*/Libs: -L${libdir} -lmediaxx/' $pkgconfig_path/$1
    sed -i '/^Requires\.private:/d' $pkgconfig_path/$1
}

reset 'libavcodec.pc'
reset 'libavformat.pc'
reset 'libavfilter.pc'
reset 'libavutil.pc'
reset 'libavdevice.pc'
reset 'libswresample.pc'
reset 'libswscale.pc'
")

ExternalProject_Add_Step(mediaxx rename-lib-pkgconfig
    DEPENDEES install
    COMMAND chmod 755 ${BACKUP_LIB}

    COMMAND ${BACKUP_LIB} ${MINGW_INSTALL_PREFIX}/lib/
    COMMENT "backup "
    LOG 1
)

ExternalProject_Add_Step(mediaxx copy-binary
    DEPENDEES install

    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmediaxx.dll           ${CMAKE_SOURCE_DIR}/output/libmediaxx.dll
    COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libmediaxx.dll.a         ${CMAKE_SOURCE_DIR}/output/libmediaxx.dll.a

    COMMAND ${CMAKE_SOURCE_DIR}/clang_root/bin/llvm-strip --strip-all      ${CMAKE_SOURCE_DIR}/output/libmediaxx.dll

    COMMENT "Copying ffmpeg binaries and manual"
)

# ExternalProject_Add_Step(mediaxx remove-ffmpeg
#     DEPENDEES install
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/avfilter.lib
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/avutil.lib
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/avdevice.lib
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/avcodec.lib
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/avformat.lib
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/swresample.lib
#     COMMAND ${CMAKE_COMMAND} -E remove ${MINGW_INSTALL_PREFIX}/lib/swscale.lib
# )

# cleanup(mediaxx rename-lib-pkgconfig)