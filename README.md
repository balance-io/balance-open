#Balance

For, like, looking at your bank accounts and stuff.

##SETUP
The project uses Carthage to build dependencies, all binaries are checked in so to build and run the project you don't need to run any Carthage command.

If you want to update a library run:
`carthage update <libName> --platform "osx ios"`

To install a new library follow Carthage documentation

## APP ARCHITECTURE

Realm layer
Database layer for searches and feed

## TESTS

Unit tests are under `BalanceUnitTests` they run with CMD+U
Currently small amount of unit tests on Feed and Searches

