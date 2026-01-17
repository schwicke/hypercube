all: clean build
clean:
	find . -name \*.ppu -exec rm \{} \;
	find . -name \*.o -exec rm \{} \;
	if [ -e cube ]; then rm cube; fi
	if [ -e interfere ]; then rm interfere; fi
	if [ -e dpplpndl ]; then rm dpplpndl; fi

build: cube interfere dpplpndl

cube:
	cd src; fpc -g cube.pas
	mv src/cube .
interfere:
	cd src; fpc -g interfere.pas
	mv src/interfere .
dpplpndl:
	cd src; fpc -g dpplpndl.pas
	mv src/dpplpndl .
