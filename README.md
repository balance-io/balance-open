<p align="center">
  <a href="https://balancemy.money">
    <img src="assets/img/balance-header.svg" />
  </a>
  <br>
  <strong>An app for all the world’s currencies</strong>
</p>
<p align="center">
  <a href="https://circleci.com/gh/balancemymoney/balance-open/">
    <img src="https://img.shields.io/circleci/project/github/balancemymoney/balance-open.svg?style=flat-square"/>
  </a>
  <a href="https://github.com/balancemymoney/balance-open/releases/">
    <img src="https://img.shields.io/github/release/balancemymoney/balance-open/all.svg?style=flat-square"/>
  </a>
  <img src="https://img.shields.io/github/license/balancemymoney/balance-open.svg?style=flat-square"/>
</p>

<p align="center">
  <br><br>
  <img src="https://cl.ly/453225333E0u/balance-open.png" alt="Balance Open Menubar App" />
  <br><br>
</p>

## Installation
1. Make sure you have Xcode 9 as the app is now written in Swift 4
2. Clone the repository: `git clone git@github.com:balancemymoney/balance-open.git`
3. Open the project in Xcode
4. Disable signing for debug builds or alternatively change the app bundle ID and sign with your developer account
5. Build and run from Xcode

## Updating dependencies
We use carthage for dependency management, however we check in all built frameworks, so it is not necessary to run any carthage commands.

However, if moving to a new Swift version, or for other reasons, it may be necessary to rebuild them using `carthage update --platform "osx, ios"`.

The easiest way to install Carthage is to install Homebrew by running `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
` and then run `brew install carthage`.

If you already have Homebrew installed, make sure to run `brew update && brew upgrade` first to to make sure you have the latest version of Carthage.

If for some reason the sqlcipher needs to be updated (you should never need to do this), run the `build_sqlcipher` script in the root of this repository and then move the `libsqlcipher.a` file that it creates on your desktop to the `./Balance/Shared/Frameworks/` folder.

## Contributing

- If you **need help** or you'd like to **ask a general question**, [open an issue](https://github.com/balancemymoney/balance-open/issues/new).
- If you **found a bug**, [open an issue](https://github.com/balancemymoney/balance-open/issues/new).
- If you **have a feature request**, [comment, upvote or create a new Trello card](https://trello.com/b/Hbg05zQO/feature-request).
- If you **want to contribute**, submit a pull request.
- Extra: If you choose to build with debug code signing disabled, since we use keychain you will be prompted on this screen at least once for every exchange you have connected. You should press "Always allow", though after about a minute or so it will forget the choice and prompt again on the next run. We haven't found a better way to do this yet.
<img width="434" alt="screen shot 2017-10-25 at 17 15 19" src="https://user-images.githubusercontent.com/1092080/32006966-842eac82-b9a8-11e7-994e-57d0cf5d0d9c.png">
