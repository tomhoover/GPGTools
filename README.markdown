# GPGTools Installer

The source code of an installer for Mac OSX that contains everything for mailing with GnuPG (see [http://gnupg.org](http://gnupg.org)).

It contains the following Applications (have a look at VERSIONS.txt to see which versions are used):

* GnuPG 1 - The basic GnuPG application from [http://gnupg.org](http://gnupg.org)
* GPGAgent - A daemon that handles your passphrases
* GPGPinentry - Application to enter your passphrases (it is used by all applications that require a GPG passphrase from you)
* GPGKeychainAccess - Application to easily manage and create you GPG keys
* GPGMail - Plugin for Apple Mail to sign/encrypt/verify/decrypt emails

**Why we use "GnuPG 1" and not "GnuPG 2":**  
First we have to clarify that "GnuPG 1" is not an "old" version of GnuPG. They are both still in active developement!  
The reason why "GnuPG 2" was created is mainly because it introduced a modular concept for GnuPG. **The functionality regarding GnuPG tasks is the same!**  
The main advantages of "GnuPG 1" are:

* no overhead due to the non modular concept
* faster than the modular "GnuPG 2" (not significantly but still)
* "GnuPG 1" is in a later state of development and therefore more stable than "GnuPG 2"

That makes "GnuPG 1" the perfect choice for GPGTools!
