rm -rf ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/
mkdir ${HOME}/libs/ymir_std/std/
mkdir ${HOME}/libs/ymir_std/core/
mkdir ${HOME}/libs/ymir_std/libs/
mkdir ${HOME}/libs/ymir_std/libs/core
mkdir ${HOME}/libs/ymir_std/libs/std
mkdir ${HOME}/libs/ymir_std/libs.g/
mkdir ${HOME}/libs/ymir_std/libs.g/core
mkdir ${HOME}/libs/ymir_std/libs.g/std

cp -r std/. ${HOME}/libs/ymir_std/std/
cp -r core/. ${HOME}/libs/ymir_std/core/

echo "Compilation de la std en release"
echo "================================="
cd ${HOME}/libs/ymir_std/
ymir -c std/stdio/*.yr
ymir -c std/algorithm/*.yr
ymir --std -c std/*.yr

gcc -c std/*/*.c

mv *.o libs/std/

ymir -c core/*.yr
mv *.o libs/core/

echo " Compilation de la std en debug  "
echo "================================="

cd ${HOME}/libs/ymir_std/
ymir -c -g std/stdio/*.yr
ymir -c -g std/algorithm/*.yr
ymir --std -c -g std/*.yr

gcc -c -g std/*/*.c

mv *.o libs.g/std/

ymir -c core/*.yr
mv *.o libs.g/core/
echo "================================="


