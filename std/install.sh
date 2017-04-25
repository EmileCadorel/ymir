rm -rf ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/std/
mkdir ${HOME}/libs/ymir_std/core/
mkdir ${HOME}/libs/ymir_std/libs/
mkdir ${HOME}/libs/ymir_std/libs/core
mkdir ${HOME}/libs/ymir_std/libs/std

cp -r std/. ${HOME}/libs/ymir_std/std/
cp -r core/. ${HOME}/libs/ymir_std/core/

cd ${HOME}/libs/ymir_std/
ymir -c std/stdio/*.yr
ymir -c std/algorithm/*.yr
ymir --std -c std/*.yr

gcc -c std/*/*.c

mv *.o libs/std/

ymir -c core/*.yr
mv *.o libs/core/


