all:
	dub build --parallel

std: final
	./std/install.sh

final:
	dub build --parallel --build=release

clean:
	dub clean
	rm *.s
	rm test/*.s
	rm ymir
	rm a.out
	rm out.s

install: final
	cp ymir ${HOME}/libs/ymir
	./std/install.sh
