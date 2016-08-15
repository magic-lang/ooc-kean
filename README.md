# Release  2.5.0

magic-sdk (formerly ooc-kean)
========
This is an extended SDK for `magic`, a high-level cross-platform language which transpiles into C99.

## History
This project was originally a fork of the [ooc project](https://github.com/fasterthanlime/rock) and contains ports of selected parts of the C# library [Kean](https://github.com/cogneco/Kean). The most notable changes include dropping garbage collection. It also uses [Sean Barrett's stb library](https://github.com/nothings/stb) for opening and saving images.

## How to run
To compile, you need the `magic` version of the [Rock compiler](https://github.com/magic-lang/rock). To make life easy, you might also want an editor with ooc/magic syntax highlighting support and a style enforcer. Those are available (for Ubuntu) at the [magic-tools repo](https://github.com/magic-lang/magic-tools#installation-ubuntu), which can also be used to automatically install (and update) rock.

Tests can be run using the `test.sh` script.

### Dependencies
The following software is necessary to build ooc-kean:
* [rock 1.0.20](https://github.com/magic-lang/rock/releases/tag/rock_1.0.20)
* gcc 4.8.4

### Linux
ooc-kean have been built and tested on the following platforms:
* Ubuntu 14.04
* Android 4.4.4 KitKat
* Android 5.0 Lollipop
* Android 5.1 Lollipop
* Android 6.0 Marshmallow
* Android 6.1 Marshmallov

### Microsoft Windows
ooc-kean have been built and tested on the following platforms:
* Built with `MinGW` on Windows 7

### OS-X
Only experimental support.

## How to learn magic
The above however target the original ooc language and are as such getting more and more outdated. A slightly more updated version is available [here](https://github.com/magic-lang/doc). We try our best to follow the `magic` style guide available also available there.

You might also take a look at the original resources for `ooc`, for example:

- [The original ooc documentation](https://ooc-lang.org/docs/)
- [The original ooc tutorial](https://ooc-lang.org/docs/tutorial/)
- [Wikibooks](https://en.wikibooks.org/wiki/Programming_with_ooc)

Note that they are quickly getting outdated.

They should all, in any case, together with reading the source of this project, be enough to get you started.

## How to contribute
Bugs are reported, with as much detail and accuracy as possible, directly to our issue list here on GitHub.

## License
This project is available under the MIT License. Please read the LICENSE document for more information.
