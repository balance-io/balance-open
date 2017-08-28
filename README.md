<h3 align="center">
  <img src="https://cl.ly/453225333E0u/balance-open.png" alt="Balance Open Menubar App" />
</h3>

Balance Open: An app for all the world’s currencies.
==========================

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]

## Installation
1. Make sure you have the latest version of the Xcode 8 (will be migrating to Xcode 9 and Swift 4 soon).
2. Clone the repository: `git clone git@github.com:balancemymoney/balance-open.git`
3. Open the project in Xcode
4. Build and run
5. There is no step 5, that's it!

## Updating dependencies
We use carthage for dependency management, however we check in all built frameworks, so it is not necessary to run any carthage commands. 

However, if moving to a new Swift version, or for other reasons, it may be necessary to rebuild them using `carthage update --platform "osx, ios"`. 

The easiest way to install Carthage is to install Homebrew by running `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
` and then run `brew install carthage`. 

If you already have Homebrew installed, make sure to run `brew update && brew upgrade` first to to make sure you have the latest version of Carthage.

If for some reason the sqlcipher needs to be updated (you should never need to do this), the following is the correct build command for that project to get the correct sqlite flags:

```
./configure --enable-tempstore=yes --with-crypto-lib=commoncrypto CFLAGS="-mmacosx-version-min=10.11 -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLITE_SOUNDEX=1 -DSQLITE_ENABLE_API_ARMOR=1 -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1 -DSQLITE_ENABLE_LOCKING_STYLE=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -DSQLITE_OMIT_AUTORESET=1 -DSQLITE_OMIT_BUILTIN_TEST=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_SYSTEM_MALLOC=1 -DSQLITE_THREADSAFE=2" LDFLAGS="-framework Security -framework CoreFoundation" && make
```

## Contributing

- If you **need help** or you'd like to **ask a general question**, [open an issue](https://github.com/balancemymoney/balance-open/issues/new).
- If you **found a bug**, [open an issue](https://github.com/balancemymoney/balance-open/issues/new).
- If you **have a feature request**, [open an issue](https://github.com/balancemymoney/balance-open/issues/new).
- If you **want to contribute**, submit a pull request.

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/aur/license/yaourt.svg
[license-url]: LICENSE
