all:
	dub build --parallel

final:
	dub build --parallel --build=release

clean:
	dub clean
	rm ymir
	rm a.out
	rm out.s

install: final
	mv ymir ${HOME}/libs/ymir
