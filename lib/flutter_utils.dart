import 'package:gradle_repo_manager/gradle_repo_manager.dart';

import 'command_line_tools.dart';
import 'directory_lookup.dart';

Future<void> applyToFlutter({
  required List<String> repos,
  required bool isVerbose,
  required bool omitFlag,
  required String pattern,
}) async {
  try {
    await for (final directory in getPubDirectories()) {
      cli.printToConsole('Found Pub Dir: ${directory.path}');
      return scanAndChangeRepos(
        isVerbose: isVerbose,
        repos: repos,
        workingDirectory: directory.absolute.path,
        omitFlag: omitFlag,
        pattern: pattern,
      );
    }
  } on Exception catch (e) {
    print(e);
  }
}
