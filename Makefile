all: build

build:
	@./scripts/create_dmg.sh

clean:
	rm -rf build

test:
	sudo installer -verboseR -pkg build/GPGTools.mpkg -target /
	gpg2 --version
