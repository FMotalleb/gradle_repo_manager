import 'dart:io';

import 'package:path/path.dart';

Future<void> unlinkGradleCaches({required bool isVerbose}) async {
  final os = Platform.operatingSystem;
  String cachesLocation;
  switch (os) {
    case 'windows':
      final usersDir = Platform.environment['USERPROFILE'];
      if (usersDir == null) {
        throw Exception('''
cannot find user dir in your environment.
you may solve this issue by setting `USERPROFILE` to `C:/users/<Your Username>`
in environment variables.
''');
      }
      cachesLocation = join(usersDir, '.gradle/caches');
      break;
    case 'linux':
      cachesLocation = join('~', '.gradle/caches');
      break;
    default:
      throw UnimplementedError('removing caches of gradle is not supported in your os ($os)');
  }
  if (isVerbose) {
    print('detected gradle caches location at `$cachesLocation`.');
  }
  try {
    await Directory(cachesLocation).delete(recursive: true);
  } on Exception catch (e) {
    print(e.toString());
  }
  if (isVerbose) {
    print('gradle caches removed.');
  }
}
