import 'package:gradle_repo_manager/gradle_repo_manager.dart';
import 'package:logging/logging.dart';
import 'directory_lookup.dart';

final _logger = Logger('FlutterUtils');
Future<void> applyToFlutter({
  required List<String> repos,
  required bool omitFlag,
  required bool watch,
  required String pattern,
}) async {
  try {
    await for (final directory in getPubDirectories()) {
      _logger.config('Found Pub Dir: ${directory.path}');
      await scanAndChangeRepos(
        repos: repos,
        workingDirectory: directory.absolute.path,
        omitFlag: omitFlag,
        pattern: pattern,
        watch: watch,
      ).onError(
        (error, stackTrace) => _logger.severe(error),
      );
    }
  } on Exception catch (e, st) {
    _logger.shout(e, e, st);
  }
}
