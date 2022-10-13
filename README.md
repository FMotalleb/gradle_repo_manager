# gradle_repo_manager

## ALERT

**content of this file are deprecated by version(2.0.0) use `--help (-h)` flag with cli**

a simple command line tool to add a repository to all gradle files under working directory
by default will add

```gradle
maven {url 'https://gradle.iranrepo.ir' }
```

if you want to use other repos use

```bash
gradle_repo_manager <repo line i.e.: maven {url 'https://gradle.iranrepo.ir' } >
gradle_repo_manager --repo--address  https://gradle.iranrepo.ir
```

without any thing around it

## in linux

`sudo ./build.sh` will build and
move executable file to `/usr/bin/repo`

## in windows

`build` will build and
copy executable file to `C:/windows/repo.exe`

so in this case you can simply use `repo` command in terminal

if you want to use it for flutter packages go to
<`flutter sdk directory`>/.pub-cache/
and run the command there
