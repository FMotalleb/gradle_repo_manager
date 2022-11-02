import 'dart:io';

import 'package:args/args.dart';
import 'package:gradle_repo_manager/gradle_repo_manager.dart' as gradle_repo_manager;
import 'package:gradle_repo_manager/gradle_utils.dart';

void main(List<String> arguments) async {
  ArgResults? params;

  try {
    params = _argParser.parse(arguments);
  } catch (e) {
    if (e is FormatException) {
      print(e.message);
    } else {
      print('unknown exception in params $e');
    }
    exit(1);
  }
  if (params['help'] == true) {
    print(_argParser.usage);
    exit(0);
  }
  if (params['gradle-cache'] == true) {
    unlinkGradleCaches(isVerbose: params['verbose'] == true);
  }
  await gradle_repo_manager.scanAndChangeRepos(
    repoPath: params['repo-address'],
    workingDirectory: params['working-directory'],
    isVerbose: params['verbose'] == true,
  );
}

ArgParser get _argParser {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'show this message',
      defaultsTo: false,
      negatable: false,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      defaultsTo: false,
      negatable: false,
      help: 'verbose mode for more detailed output',
    )
    ..addOption(
      'working-directory',
      abbr: 'd',
      aliases: [
        'directory',
        'root',
      ],
      valueHelp: 'must be a valid directory',
      callback: (p0) {
        if (p0 == null || !Directory(p0).existsSync()) {
          print('please enter correct directory, given value ($p0) is not acceptable');
          exit(1);
        }
      },
      help: 'set root project(s) directory to search for gradle files',
      defaultsTo: Directory.current.path,
    )
    ..addOption(
      'repo-address',
      abbr: 'r',
      valueHelp: 'must be (http|https) url',
      callback: (p0) {
        final checker = Uri.tryParse(p0 ?? 'none');
        if (checker == null) {
          print('given value `$p0` cannot be parsed as url');
          exit(1);
        } else if (checker.isScheme('http') || checker.isScheme('https')) {
          return;
        }
        print('given value `$p0` is not valid');
        exit(1);
      },
      defaultsTo: 'https://gradle.iranrepo.ir',
      help: 'new repository address to add to all sub gradle dirs',
    )
    ..addFlag(
      'gradle-cache',
      abbr: 'c',
      defaultsTo: false,
      negatable: false,
      help: 'removes gradle cache directory',
    );
}
