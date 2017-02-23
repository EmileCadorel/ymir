rm -rf ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/std/
mkdir ${HOME}/libs/ymir_std/libs/

cp -r std/. ${HOME}/libs/ymir_std/std/

cd ${HOME}/libs/ymir_std/
ymir -c std/stdio/*.yr
ymir --std -c std/*.yr
gcc -c std/*/*.c

mv *.o libs/


