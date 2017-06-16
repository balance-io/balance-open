<h3 align="center">
  <img src="https://cl.ly/453225333E0u/balance-open.png" alt="Balance Open Menubar App" />
</h3>

Balance Open: A GPL3-licensed macOS menu bar app for all the world’s currencies.
==========================

## Installation
Make sure you have the latest version of the Xcode.

You will need to run a `sqlcipher` compile command to update the app:

```
./configure --enable-tempstore=yes --with-crypto-lib=commoncrypto CFLAGS="-mmacosx-version-min=10.11 -DSQLITE_HAS_CODEC -DSQLITE_TEMP_STORE=2 -DSQLITE_SOUNDEX=1 -DSQLITE_ENABLE_API_ARMOR=1 -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1 -DSQLITE_ENABLE_LOCKING_STYLE=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -DSQLITE_OMIT_AUTORESET=1 -DSQLITE_OMIT_BUILTIN_TEST=1 -DSQLITE_OMIT_LOAD_EXTENSION=1 -DSQLITE_SYSTEM_MALLOC=1 -DSQLITE_THREADSAFE=2" LDFLAGS="-framework Security -framework CoreFoundation" && make
```
