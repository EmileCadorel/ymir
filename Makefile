all:
	dub build --parallel

final:
	dub build --parallel --build=release

clean:
	dub clean
	rm ymir
