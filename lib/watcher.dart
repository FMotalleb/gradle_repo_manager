import 'dart:io';

import 'package:logging/logging.dart';

import 'gradle_repo_manager.dart';

final _logger = Logger('Watcher');
Future<void> watchDirectory(
  Directory directory, {
  required bool omitFlag,
  required List<String> repos,
  required String pattern,
}) async {
  _logger.config('watching: ${directory.path}');
  final watcher = directory
      .watch(recursive: true)
      .where((event) =>
          (event is FileSystemCreateEvent || event is FileSystemModifyEvent) &&
          event.isDirectory == false &&
          event.path.endsWith('.gradle')) //
      .map(
        (event) => File(event.path),
      )..forEach(
      (element) {
        _logger.fine('Change Detected: $element');
      },
    );
  await for (final event in watcher) {
    final filePath = event.path;
    _logger.info('new gradle file found: $filePath');
    for (final address in repos) {
      if (omitFlag) {
        await removeRepo(
          sourceFile: event,
          pattern: pattern,
          repoAddress: address,
        );
      } else {
        await setRepo(
          sourceFile: event,
          pattern: pattern,
          repoAddress: address,
        );
      }
    }
  }
}
