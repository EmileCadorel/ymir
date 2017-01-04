all:
	dub build --parallel

final:
	dub build --parallel --build=release

clean:
	dub clean
	rm __precompiled__.s
	rm test/*.s
	rm ymir
	rm a.out
	rm out.s

install: final
	cp ymir ${HOME}/libs/ymir
	make clean
