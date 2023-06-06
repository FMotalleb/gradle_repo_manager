import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:hemend_logger/hemend_logger.dart';

final _logger = Logger('DirectoryLookup');
Stream<Directory> getPubDirectories() async* {
  yield await _getInstallationPath();
  if (Platform.isWindows) {
    yield* _lookup<Directory>('C:\\Users\\*\\AppData\\Local\\Pub\\Cache');
  } else if (Platform.isLinux || Platform.isMacOS) {
    yield* _lookup<Directory>('/home/*/.pub-cache');
  }
}

Stream<T> _lookup<T extends FileSystemEntity>(String pattern) => Glob(pattern)
    .list()
    .where(
      (event) => event is T,
    )
    .cast();

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
        _logger.severe('Cannot find flutter sdk path.');
        throw Exception('Cannot find flutter sdk path.');
      }
      _logger.config('Flutter Directory Found: $dir');
      doctorProcess.kill();
      return Directory(dir);
    }
  }
  _logger.severe('Cannot find flutter sdk path.');
  throw Exception('Cannot find flutter sdk path.');
}
