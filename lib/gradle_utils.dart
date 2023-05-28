import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';

final _logger = Logger('Watcher');
Future<void> unlinkGradleCaches() async {
  final os = Platform.operatingSystem;

  String cachesLocation;
  switch (os) {
    case 'windows':
      _logger.config('detected Operation System: $os');
      final usersDir = Platform.environment['USERPROFILE'];
      if (usersDir == null) {
        var error = '''
cannot find user directory in your environment.
you may solve this issue by setting `USERPROFILE` to `C:/users/<Your Username>`
in environment variables.
''';
        _logger.shout(error);
        throw Exception(error);
      }
      cachesLocation = join(usersDir, '.gradle/caches');
      break;
    case 'linux':
      _logger.config('detected Operation System: $os');
      final usersDir = Platform.environment['HOME'];
      if (usersDir == null) {
        var error = '''
cannot find user directory in your environment.
you may solve this issue by setting `HOME` to `/home/<Your Username>`
in environment variables.
or for this run use 
export HOME=/home/<Your Username>
''';
        _logger.shout(error);
        throw Exception(error);
      }
      cachesLocation = join(usersDir, '.gradle/caches');
      break;
    default:
      throw UnimplementedError(
        //
        'removing caches of gradle is not supported in your os ($os)',
      );
  }
  _logger.fine('detected gradle caches location at `$cachesLocation`.');

  try {
    await Directory(cachesLocation).delete(recursive: true);
  } on Exception catch (e, st) {
    _logger.severe(e, e, st);
  }
  _logger.fine('gradle caches removed.');
}
