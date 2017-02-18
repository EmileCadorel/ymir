cp -r std/ ${HOME}/libs/ymir_std/std/
cd ${HOME}/libs/ymir_std/
ymir --std -c std/*.yr
ymir -c std/stdio/*.yr
rm -rf libs/
mkdir libs
mv *.o libs/
