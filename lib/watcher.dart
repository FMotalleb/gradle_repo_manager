import 'dart:io';

import 'command_line_tools.dart';
import 'gradle_repo_manager.dart';

Future<void> watchDirectory(
  Directory directory, {
  required bool omitFlag,
  required List<String> repos,
  required bool isVerbose,
  required String pattern,
}) async {
  cli.printToConsole('watching: ${directory.path}');
  final watcher = directory
      .watch(recursive: true)
      .where((event) =>
          (event is FileSystemCreateEvent || event is FileSystemModifyEvent) &&
          event.isDirectory == false &&
          event.path.endsWith('.gradle')) //
      .map(
        (event) => File(event.path),
      )..forEach((element) {
      print(element);
    });
  await for (final event in watcher) {
    final filePath = event.path;
    cli.printToConsole('new gradle file found: $filePath');
    for (final address in repos) {
      if (omitFlag) {
        await removeRepo(
          sourceFile: event,
          isVerbose: isVerbose,
          pattern: pattern,
          repoAddress: address,
        );
      } else {
        await setRepo(
          sourceFile: event,
          isVerbose: isVerbose,
          pattern: pattern,
          repoAddress: address,
        );
      }
    }
  }
}
