import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:gradle_repo_manager/watcher.dart';

Future<void> scanAndChangeRepos({
  required List<String> repos,
  required String workingDirectory,
  required bool isVerbose,
  required bool omitFlag,
  required String pattern,
  required bool watch,
}) async {
  final workingDir = Directory(workingDirectory);
  if (watch) {
    watchDirectory(
      workingDir,
      omitFlag: omitFlag,
      repos: repos,
      isVerbose: isVerbose,
      pattern: pattern,
    );
  }
  final globMatcher = Glob("**/*.gradle");

  for (final repoPath in repos) {
    if (isVerbose) {
      print('working dir: ${workingDir.absolute.path}');
      print('repo: $repoPath');
    }
    final startTime = DateTime.now().millisecondsSinceEpoch;
    int totalCounter = 0;
    int doneCount = 0;
    await for (final i in scanForFiles(
      root: workingDir,
      isVerbose: isVerbose,
      globMatcher: globMatcher,
    )) {
      totalCounter++;
      final bool result;
      if (omitFlag) {
        result = await removeRepo(
          sourceFile: i,
          repoAddress: repoPath,
          isVerbose: isVerbose,
          pattern: pattern,
        );
      } else {
        result = await setRepo(
          sourceFile: i,
          repoAddress: repoPath,
          isVerbose: isVerbose,
          pattern: pattern,
        );
      }
      doneCount += result ? 1 : 0;
    }
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final totalDur = endTime - startTime;

    print(
      'scanned `$totalCounter` file(s), added repo to `$doneCount` file(s), in ${totalDur}ms.',
    );
  }
}

Stream<File> scanForFiles({
  required Directory root,
  required Glob globMatcher,
  required bool isVerbose,
}) {
  return globMatcher
      .list(
    root: root.absolute.path,
    followLinks: false,
  )
      .where(
    (event) {
      return event is File;
    },
  ).map<File>(
    (event) {
      if (event is File) {
        if (isVerbose) {
          print('found ${event.path}');
        }
        return event as File;
      }
      throw Exception('event is not a file actually its impossible');
    },
  );
}

Future<bool> setRepo({
  required File sourceFile,
  required String repoAddress,
  required bool isVerbose,
  required String pattern,
}) async {
  final repo = pattern.replaceAll('\${repo}', repoAddress);
  // 'maven { url \'$repoAddress\' }';
  final oldValue = sourceFile.readAsStringSync();
  final repoStartingPoint = RegExp(r'repositories\s*{');
  if (!oldValue.contains(repoStartingPoint)) {
    if (isVerbose) {
      print(
        //
        'cannot find any repository entry in `${sourceFile.path}` <it isn\'t an error>',
      );
    }
    return false;
  } else if (oldValue.contains(repoAddress)) {
    if (isVerbose) print('repo already exists in `${sourceFile.path}`');
    return false;
  } else {
    final newVal = oldValue.replaceAll(repoStartingPoint, '''
repositories {
        $repo''');
    sourceFile.writeAsStringSync(newVal);
    if (isVerbose) print('repo added to `${sourceFile.path}`');
    return true;
  }
}

Future<bool> removeRepo({
  required File sourceFile,
  required String repoAddress,
  required bool isVerbose,
  required String pattern,
}) async {
  final repo = pattern.replaceAll('\${repo}', repoAddress);
  final sfStr = sourceFile.readAsStringSync();
  final repoStartingPoint = RegExp(r'repositories\s*{');
  if (!sfStr.contains(repoStartingPoint)) {
    if (isVerbose) {
      print(
        'cannot find any repository entry in `${sourceFile.path}` <it isn\'t an error>',
      );
    }
    return false;
  } else if (sfStr.contains(repoAddress)) {
    final newVal = sfStr.replaceAll(repo, '');
    if (isVerbose) print('removed repo from `${sourceFile.path}`');
    sourceFile.writeAsStringSync(newVal);
    return true;
  } else {
    return false;
  }
}
