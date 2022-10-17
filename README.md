# Gradle Repository Manager

## introduction

a simple command line tool to add a repository to all gradle files under working directory

the reason was default gradle repos sanctions against the country I live in so android
builds would fail due to limitations applied

1. this cli will scan all subdirectories for `*.gradle` files
2. find repository entry in the file (some of files does not include one)
3. add a custom repository at start of the repositories list

## Building

### in linux

`sudo ./build.sh` will build and
move executable file to `/usr/bin/repo`
so you can access from every where using `repo` cli

### in windows

`./build.bat` will build and
copy executable file to `C:/windows/repo.exe`
(i have not tested this yet but it should work)

>so in this case you can simply use `repo` command in terminal

if you want to use it for flutter packages go to
<`flutter sdk directory`>/.pub-cache/
and run the command there

## usage

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

## TODO
- [ ] manage ~/.gradle/init.gradle file
- [ ] remove a repository entry
- [ ] change a repository to another one
- [ ] change default pattern of maven repository
