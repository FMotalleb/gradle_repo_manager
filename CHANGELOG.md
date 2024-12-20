## 2.9.2+1

* (Fix): now tries to loockup `.pub-cache` in `root` user of linux
* (Feat): added `--no-tls` flag

## 2.8.2+1

* (Fix): windows cache location

## 2.7.3+0

* (Minor): Dependency updated

## 2.7.2+0

* (Minor): Dependency updated

## 2.7.1+0

* (Minor): logging system changed from cli_utils to (logging | hemend_logger)

## 2.7.0+0

* (Feat) added watch mode `--watch(-w)`

## 2.6.0+0

* (Feat) can detect new .pub-cache dirs (in users directory)

## 2.5.1+1

* (Feat) added option to change pattern of repository entry using `--pattern <pattern>`
* (Feat) added Self-Update `repo update`

## 2.4.1+1

* (Fix) Omit flag affecting pub packages
* (Fix) removed `jcenter` repository

## 2.4.0+0

* (Feat) The `repo-address` (alias `-r`) option has been modified to support multiple repository addresses
* (Minor) [Aliyun](https://developer.aliyun.com/) repositories are being used instead of [IranRepo](https://iranrepo.ir/)

## 2.3.2+0

* (Fix) `dart-cmd` would not interrupt work flow

## 2.3.1+1

* (Refactor)

## 2.3.1+0

* (Feat) Omit Flag 76814ad0f680fdb729d44bac6adf180fc0c13dcc
* (Feat) Create .github/dependabot.yml ce470e5bf4bee9fc76f221eb15c344cc4bda8336
* (Deps) cli_utils 0.3.5 -> 0.4.0 841b7c248bda52a464884588dd7591bdf020a90d
* (Minor, Typo) 8f21a8cf6545ee91b0c875cc65d549cd638cbd7d
* (Minor, Typo) f507d5c58bf9307bbe11337c2ce1bbcbe6dea25a
* (Minor, Typo) 0e865a88ab817b1059c4cbb44e712d0785628a8a
* tanks to [Hamidreza Bayat](https://github.com/HrBDev)

## 2.2.1+0

* (Feat) added ability to set custom environments for dart-cmd

## 2.2.0+0

* (Feat) added option to run dart command with custom host and storage urls

## 2.1.0

* (Release) stable release

## 2.0.3

* (Feat) now can detect flutter sdk path
and update gradle files with (--pub-packages || -p)

## 2.0.2

* (Fix) fixed gradle caches remove method for linux

## 2.0.1

* (Feat) remove gradle caches using (--gradle-cache || -c)

## 2.0.0

* (feat) supports arguments for changing working directory and repo address

## 1.0.0

* Initial version.
