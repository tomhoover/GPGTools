all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

dmg:
	@./scripts/compile.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh

clean:
	rm -rf build
	rm -rf payload/keychain_access/Applications/*
	rm -rf payload/gpgservices/*
	rm -rf payload/gpgmail/*

test:
	@echo " * Uninstalling gpg2...";
	@sudo osascript Uninstall_GPGTools.app/Contents/Resources/Scripts/remover.scpt > make.log 2>&1
	@gpg2 --version 2>/dev/null; if [ "$?" == "0" ] || [ ! "`which gpg2`" == "" ]; then echo "FAIL"; exit 1; else echo "PASS"; fi
	@echo " * Installing gpg2...";
	@sudo installer -verboseR -pkg build/GPGTools.mpkg -target /  > make.log 2>&1
	@sudo chown -R $$USER ~/.gnupg
	@sudo chown -R $$USER ~/Library/Mail/Bundles
	@if [ "`gpg2 --version|grep 2.0.17`" == "" ]; then echo "FAIL"; exit 1; else echo "PASS"; fi
	@echo "Done.";
