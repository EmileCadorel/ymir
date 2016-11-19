all:
	dub build --parallel

final:
	dub build --parallel --build=release

clean:
	dub clean
	rm ymir

install: all
	mv ymir ${HOME}/libs/ymir
