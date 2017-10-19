rm -rf ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/std/
mkdir ${HOME}/libs/ymir_std/core/
mkdir ${HOME}/libs/ymir_std/libs/
mkdir ${HOME}/libs/ymir_std/libs/core
mkdir ${HOME}/libs/ymir_std/libs/std
mkdir ${HOME}/libs/ymir_std/libs/std/stdio
mkdir ${HOME}/libs/ymir_std/libs/std/algorithm

cp -r std/. ${HOME}/libs/ymir_std/std/
cp -r core/. ${HOME}/libs/ymir_std/core/

cd ${HOME}/libs/ymir_std/

ymrc --lint D std/stdio/*.yr

ymrc --lint D std/algorithm/*.yr

ymrc --lint D std/*.yr

ymrc --lint D core/*.yr

#dmd -c core/*.d std/algorithm/*.d std/*.d std/stdio/*.d
#cp ~/gc/lib/libgc.a libs/libgc.a

