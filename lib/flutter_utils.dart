import 'dart:io';

import 'package:gradle_repo_manager/gradle_repo_manager.dart';

Future<void> applyToFlutter({
  required List<String> repos,
  required bool isVerbose,
  required bool omitFlag,
}) async {
  try {
    final sdkDir = await _getInstallationPath();
    return scanAndChangeRepos(
      isVerbose: isVerbose,
      repos: repos,
      workingDirectory: sdkDir.absolute.path,
      omitFlag: omitFlag,
    );
  } on Exception catch (e) {
    print(e);
  }
}

Future<Directory> _getInstallationPath() async {
  const pattern =
      r'Flutter\sversion\s(?<version>[^\s]+)\son\schannel\s(?<channelName>[^\s]*)\sat\s(?<installDir>[^\n]*)';
  final matcher = RegExp(pattern);
  final doctorProcess = await Process.start(
    'flutter',
    ['doctor', '-v'],
    runInShell: true,
    includeParentEnvironment: true,
    mode: ProcessStartMode.normal,
  );
  await for (final out in doctorProcess.stdout) {
    final outputStr = String.fromCharCodes(out);
    if (matcher.hasMatch(outputStr)) {
      final result = matcher.firstMatch(outputStr);
      final dir = result?.namedGroup('installDir');
      if (dir == null || !Directory(dir).existsSync()) {
        throw Exception('Cannot find flutter sdk path.');
      }
      doctorProcess.kill();
      return Directory(dir);
    }
  }
  throw Exception('Cannot find flutter sdk path.');
}
