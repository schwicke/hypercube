all: clean build
clean:
	find . -name \*.ppu -exec rm \{} \;
	find . -name \*.o -exec rm \{} \;
	if [ -e cube ]; then rm cube; fi
	if [ -e interfere ]; then rm interfere; fi
build: cube interfere
cube:
	cd src; fpc -g cube.pas
	mv src/cube .
interfere:
	cd src; fpc -g interfere.pas
	mv src/interfere .
