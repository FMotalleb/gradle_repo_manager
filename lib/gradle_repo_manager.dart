import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:gradle_repo_manager/watcher.dart';
import 'package:logging/logging.dart';

final _logger = Logger('RepoManager');
Future<void> scanAndChangeRepos({
  required List<String> repos,
  required String workingDirectory,
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
      pattern: pattern,
    );
  }
  final globMatcher = Glob("**/*.gradle");

  for (final repoPath in repos) {
    _logger.config('working dir: ${workingDir.absolute.path}');
    _logger.config('repo: $repoPath');

    final startTime = DateTime.now().millisecondsSinceEpoch;
    int totalCounter = 0;
    int doneCount = 0;
    await for (final i in scanForFiles(
      root: workingDir,
      globMatcher: globMatcher,
    )) {
      totalCounter++;
      final bool result;
      if (omitFlag) {
        result = await removeRepo(
          sourceFile: i,
          repoAddress: repoPath,
          pattern: pattern,
        );
      } else {
        result = await setRepo(
          sourceFile: i,
          repoAddress: repoPath,
          pattern: pattern,
        );
      }
      doneCount += result ? 1 : 0;
    }
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final totalDur = endTime - startTime;

    _logger.fine(
      'scanned `$totalCounter` file(s), added repo to `$doneCount` file(s), in ${totalDur}ms.',
    );
  }
}

Stream<File> scanForFiles({
  required Directory root,
  required Glob globMatcher,
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
        _logger.finest('found ${event.path}');

        return event as File;
      }
      throw Exception('event is not a file actually its impossible');
    },
  );
}

Future<bool> setRepo({
  required File sourceFile,
  required String repoAddress,
  required String pattern,
}) async {
  final repo = pattern.replaceAll('\${repo}', repoAddress);
  // 'maven { url \'$repoAddress\' }';
  final oldValue = sourceFile.readAsStringSync();
  final repoStartingPoint = RegExp(r'repositories\s*{');
  if (!oldValue.contains(repoStartingPoint)) {
    _logger.finest(
      'cannot find any repository entry in `${sourceFile.path}` <it isn\'t an error>',
    );

    return false;
  } else if (oldValue.contains(repoAddress)) {
    _logger.finest('repo already exists in `${sourceFile.path}`');
    return false;
  } else {
    final newVal = oldValue.replaceAll(repoStartingPoint, '''
repositories {
        $repo''');
    sourceFile.writeAsStringSync(newVal);
    _logger.finest('repo added to `${sourceFile.path}`');
    return true;
  }
}

Future<bool> removeRepo({
  required File sourceFile,
  required String repoAddress,
  required String pattern,
}) async {
  final repo = pattern.replaceAll('\${repo}', repoAddress);
  final sfStr = sourceFile.readAsStringSync();
  final repoStartingPoint = RegExp(r'repositories\s*{');
  if (!sfStr.contains(repoStartingPoint)) {
    _logger.finest(
      'cannot find any repository entry in `${sourceFile.path}`',
    );

    return false;
  } else if (sfStr.contains(repoAddress)) {
    final newVal = sfStr.replaceAll(repo, '');
    _logger.finest('removed repo from `${sourceFile.path}`');
    sourceFile.writeAsStringSync(newVal);
    return true;
  } else {
    return false;
  }
}
