dmd: 
	dub build

all:
	dub build

std: all
	cp ymir ${HOME}/libs/ymir
	./std/install.sh

final:
	dub build --build=release --parallel

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

docs: FORCE
	dub build --build=ddox
	./docs/install.sh

FORCE:
