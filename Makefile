all:
	dub build --parallel

clean:
	dub clean
	rm ymir
