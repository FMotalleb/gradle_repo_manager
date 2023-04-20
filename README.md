# Gradle Repository Manager

## Introduction

A Simple Command Line Tool to Add a Repository to All Gradle Files Under Working Directory

The purpose of this command line tool is to address the issue of default Gradle repositories sanctions against the country in which the user resides, resulting in Android builds failing due to limitations applied. This CLI will:

1. Scan all subdirectories for `*.gradle` files.
2. Find repository entry in the file (some of files does not include one).
3. Add a custom repository at the start of the repositories list.

## Installing

To install the Gradle Repository Manager, use the following command:

```bash
dart pub global activate gradle_repo_manager
```

Once the Command Line Interface (CLI) has been installed on your device, you can use it to perform various tasks.

Use Following command to show help message

```bash
repo --help
```

## Usage

### Since version 2.4.0 and higher

- The `repo-address` (alias `-r`) option has been modified to support multiple repository addresses
- [Aliyun](https://developer.aliyun.com/) repositories are being used instead of [IranRepo](https://iranrepo.ir/)

### Since version 2.0.0 and higher

**use `--help (-h)` to see help message of cli**

```bash
repo \
-d /<path/to/flutter-sdk>/.pub-cache (default: `current working directory`) \
-r <repo url (default: `https://gradle.iranrepo.ir`)> \
-v \
```

### For version 1.0.0

by default will add

```gradle
maven {url 'https://gradle.iranrepo.ir' }
```

if you want to use other repos use

```bash
repo <repo line i.e.: maven {url 'https://gradle.iranrepo.ir' } >
```

without any thing around it

## Building

### in linux

Executing `sudo ./build.sh` will build and move the executable file to `/usr/bin/repo`, allowing users to access it from any location using the `repo` command line interface (CLI).

### in windows

The `./build.bat` command can be used to build and copy the executable file to `C:/windows/repo.exe`. This has not been tested yet, but it should work. To use this for Flutter packages, navigate to the `flutter sdk directory`/.pub-cache/ and run the command there.

## TODO

### In Progress

- [ ] Add an update command that enables self-update functionality.
- [ ] Migrate to pub cache directory change.
- [ ] Implement a configuration file to store repositories, patterns, and directories for easier management and customization.

### Done

- [x] Remove a repository entry.
- [x] Modify the default pattern of Maven repository.

### Ignored

- [x] Change a repository to another one (can be done using omit).
