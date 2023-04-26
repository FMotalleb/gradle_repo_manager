import 'dart:io';

import 'package:args/args.dart';
import 'package:gradle_repo_manager/command_line_tools.dart';
import 'package:gradle_repo_manager/flutter_utils.dart' as flutter_utils;
import 'package:gradle_repo_manager/gradle_repo_manager.dart' //
    as gradle_repo_manager;
import 'package:gradle_repo_manager/gradle_utils.dart' as gradle_utils;

Future<void> main(List<String> arguments) async {
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
  cli.setVerbose(params['verbose'] == true);
  final givenCommand = params.command;
  if (givenCommand != null) {
    switch (givenCommand.name) {
      case 'dart-cmd':
        await _dartCmd(givenCommand);
        break;
      case 'update':
        await cli.runTaskInTerminal(
          name: 'update',
          command: 'dart',
          arguments: [
            'pub',
            'global',
            'activate',
            'gradle_repo_manager',
          ],
          environment: {
            'PUB_HOSTED_URL': givenCommand['pub-hosted-url'],
          },
        );
        break;
      default:
        print('unknown command: ${givenCommand.name}');
        print(_argParser.usage);
        print(
          'using `dart-cmd` you can pass a command to run using custom hosts',
        );
        print(_pubArgsParser.usage);
        exit(69);
    }
  } else {
    await _repoUpdater(params);
  }
}

Future<void> _dartCmd(ArgResults givenCommand) async {
  final command = (givenCommand['command'] ?? '').toString();
  final storageAddress = //
      (givenCommand['flutter-storage-address'] ?? '').toString();
  final pubHostedUrl = (givenCommand['pub-hosted-url'] ?? '').toString();
  final extraEnvs = List<String>.from(givenCommand['extra-env'] ?? []);
  if (command.isEmpty) {
    exitWithMessage('please provide command\n${_pubArgsParser.usage}');
  }

  await cli.runTaskInTerminal(
    name: 'dart command',
    command: command,
    arguments: [],
    environment: {
      ...Platform.environment,
      'PUB_HOSTED_URL': pubHostedUrl,
      'FLUTTER_STORAGE_BASE_URL': storageAddress,
      ...createEnvFromArgs(extraEnvs),
    },
  );
}

Future<void> _repoUpdater(ArgResults params) async {
  if (params['help'] == true) {
    print(_argParser.usage);
    print('using `dart-cmd` you can pass a command to run using custom hosts');
    print(_pubArgsParser.usage);
    exit(0);
  }
  if (params['gradle-cache'] == true) {
    await gradle_utils.unlinkGradleCaches(
      isVerbose: params['verbose'] == true,
    );
  }
  if (params['pub-packages']) {
    await flutter_utils.applyToFlutter(
      repos: params['repo-address'],
      isVerbose: params['verbose'] == true,
      omitFlag: params['omit'],
      pattern: params['pattern'],
      watch: params['watch'],
    );
  }
  try {
    await gradle_repo_manager.scanAndChangeRepos(
      repos: params['repo-address'],
      workingDirectory: params['working-directory'],
      isVerbose: params['verbose'] == true,
      omitFlag: params['omit'],
      pattern: params['pattern'],
      watch: params['watch'],
    );
  } on Exception catch (e) {
    print(e);
  }
}

Never exitWithMessage(String message, [int code = 1]) {
  cli.printToConsole(message);
  exit(code);
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
          print(
            //
            'please enter correct directory, given value ($p0) is not acceptable',
          );
          exit(1);
        }
      },
      help: 'set root project(s) directory to search for gradle files',
      defaultsTo: Directory.current.path,
    )
    ..addMultiOption(
      'repo-address',
      abbr: 'r',
      valueHelp: 'must be (http|https) urls',
      callback: (items) {
        for (final i in items) {
          final checker = Uri.tryParse(i);
          if (checker == null) {
            print('given value `$i` cannot be parsed as url');
            exit(1);
          } else if (checker.isScheme('http') || checker.isScheme('https')) {
            return;
          }
          print('given value `$i` is not valid');
          exit(1);
        }
      },
      defaultsTo: [
        'https://maven.aliyun.com/repository/central',
        'https://maven.aliyun.com/repository/google',
        // 'https://maven.aliyun.com/repository/jcenter',
      ],
      help: 'new repository addresses to add to all sub gradle dirs',
    )
    ..addOption(
      'pattern',
      defaultsTo: 'maven { url \'\${repo}\' }',
      help: 'set repository entry pattern (does affect omit flag)',
      aliases: [
        'format',
      ],
      valueHelp: //
          'pattern with \${repo} inside it',
      callback: (p0) {
        if (p0?.isNotEmpty != true) {
          print('pattern cannot be empty');
          exit(1);
        }
        if (!p0!.contains(r'${repo}')) {
          print('pattern is not valid you have to use \${repo} inside pattern');
          exit(1);
        }
      },
    )
    ..addFlag(
      'gradle-cache',
      abbr: 'c',
      defaultsTo: false,
      negatable: false,
      help: 'removes gradle cache directory from',
    )
    ..addFlag(
      'pub-packages',
      abbr: 'p',
      defaultsTo: false,
      negatable: false,
      help: //
          'finds flutter sdk path and adds desired repo address to all pub/flutter packages gradle files.',
    )
    ..addFlag(
      'watch',
      abbr: 'w',
      defaultsTo: false,
      negatable: false,
      help: //
          'watches for file changes and update repositories when found new `.gradle` files.',
    )
    ..addCommand(
      'dart-cmd',
      _pubArgsParser,
    )
    ..addCommand(
      'cmd',
      _pubArgsParser,
    )
    ..addCommand(
        'update',
        ArgParser()
          ..addOption(
            'pub-hosted-url',
            abbr: 'p',
            defaultsTo: 'https://pub.dev',
            help: 'set default url for pub packages lookup',
          ))
    ..addFlag(
      'omit',
      abbr: 'o',
      defaultsTo: false,
      negatable: false,
      help: 'removes repo instead of adding',
    );
}

ArgParser get _pubArgsParser => ArgParser()
  ..addOption(
    'command',
    abbr: 'c',
    help: 'command that will be ran using custom storage and pub address',
    valueHelp: 'add `"`s before and after command',
  )
  ..addOption(
    'flutter-storage-address',
    abbr: 's',
    defaultsTo: 'https://storage.flutter-io.cn',
    help: 'set default location for flutter storage',
  )
  ..addOption(
    'pub-hosted-url',
    abbr: 'p',
    defaultsTo: 'https://pub.flutter-io.cn',
    help: 'set default url for pub packages lookup',
  )
  ..addMultiOption(
    'extra-env',
    abbr: 'e',
    defaultsTo: [],
    help: //
        'extra environments table. format must be `<ENVIRONMENT KEY>=<VALUE>` and supports multiple values',
  );

Map<String, String> createEnvFromArgs(List<String> args) {
  return Map.fromEntries(generateEnv(args));
}

Iterable<MapEntry<String, String>> generateEnv(List<String> args) sync* {
  for (final i in args) {
    final arr = i.split('=');

    if (arr.length == 2) {
      yield MapEntry(arr.first, arr.last);
    } else {
      cli.printToConsole('given env $i is not a `<Key>=<Value>`');
    }
  }
}
