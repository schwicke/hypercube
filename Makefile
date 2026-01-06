all: clean build
clean:
	find . -name \*.ppu -exec rm \{} \;
	find . -name \*.o -exec rm \{} \;
	if [ -e cube ]; then rm cube; fi
build:
	cd src; fpc cube.pas
	mv src/cube .

