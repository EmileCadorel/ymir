.PHONY: install final dostd 

dmd: 
	dub build

all:
	dub build

std: mv dostd

final:
	dub build --build=release --parallel
	cp ymrc ${HOME}/libs/ymir

clean:
	dub clean
	rm ymir
	rm a.out
	rm *.s
	rm test/*.s

install: final dostd

dostd:
	./std/install.sh

uninstall:
	rm ${HOME}/libs/ymir
	rm -rf ${HOME}/libs/ymir_std/*

docs: FORCE
	dub build --build=ddox
	./docs/install.sh

mv:     all
	cp ymrc ${HOME}/libs/ymir

.PHONY: install

