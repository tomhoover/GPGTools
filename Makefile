all: build

build:
	@./scripts/create_dmg.sh

clean:
	rm -rf build

test:
	#sudo rm -f `which gpg2`
	#gpg2 --version 2>/dev/null; if [ "$?" == "0" ]; then echo "FAIL"; exit 1; fi
	sudo installer -verboseR -pkg build/GPGTools.mpkg -target /
	sudo chown -R $$USER ~/.gnupg
	#gpg2 --version; if [ "$?" != "0" ]; then echo "FAIL"; exit 1; fi

