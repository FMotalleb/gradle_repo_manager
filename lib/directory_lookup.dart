import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

Stream<Directory> getPubDirectories() async* {
  yield await _getInstallationPath();
  if (Platform.isWindows) {
    yield* Glob("C:/Users/*/.pub-cache")
        .list()
        .where(
          (event) => event is Directory,
        )
        .cast();
  } else if (Platform.isLinux || Platform.isMacOS) {
    final possibleDir = Directory('~/.pub-cache');
    if (await possibleDir.exists()) {
      yield possibleDir;
    }
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
