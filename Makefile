all:
	dub build --parallel

std: all
	cp ymir ${HOME}/libs/ymir
	./std/install.sh

final:
	dub build --parallel --build=release

clean:
	dub clean
	rm ymir
	rm a.out
	rm *.s
	rm test/*.s

install: final
	cp ymir ${HOME}/libs/ymir
	./std/install.sh


uninstall:
	rm ${HOME}/libs/ymir
	rm -rf ${HOME}/libs/ymir_std/*
