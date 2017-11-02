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
cp std/dub.json ${HOME}/libs/ymir_std/

cd ${HOME}/libs/ymir_std/

ymir -ol std/stdio/*.yr std/algorithm/*.yr std/*.yr core/*.yr
dub add-local .
dub  

