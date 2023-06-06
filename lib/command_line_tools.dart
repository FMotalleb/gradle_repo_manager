import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:hemend_logger/hemend_logger.dart';
import 'package:logging/logging.dart' as logging;

final HemTerminal cli = HemTerminal._();

class HemTerminal {
  HemTerminal._();

  String readLineFromConsole() => io.stdin.readLineSync() ?? '';

  Future<io.ProcessResult> runTaskInTerminal({
    required String name,
    required String command,
    required List<String> arguments,
    bool isAdminCmd = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = true,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
    required logging.Logger logger,
  }) async {
    logger.finest('running os task $name: $command ${arguments.join(' ')}');

    _ProcessParams params;
    if (Platform.isLinux || Platform.isMacOS) {
      params = _ProcessParams(
        isAdminCmd ? 'sudo' : '/bin/sh',
        [
          if (isAdminCmd) '/bin/sh',
          '-c',
          [
            command,
            ...arguments,
          ].join(' '),
        ],
      );
    } else if (Platform.isWindows) {
      params = _ProcessParams(
        'cmd',
        [
          '/c',
          [
            command,
            ...arguments,
          ].join(' '),
        ],
      );
    } else {
      throw UnsupportedError('current os is not supported');
    }
    final process = await Process.start(
      params.exe,
      params.args,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
    );

    final stdOutFuture = process.stdout.fold<List<String>>(
      <String>[],
      (previous, element) {
        final newVal = String.fromCharCodes(element);
        logger.config(
          newVal,
        );
        return <String>[
          ...previous,
          newVal,
        ];
      },
    );
    final stdErrFuture = process.stderr.fold<List<String>>(
      <String>[],
      (previous, element) {
        final newVal = String.fromCharCodes(element);
        logger.severe(
          newVal,
        );
        return <String>[
          ...previous,
          newVal,
        ];
      },
    );
    final exitCode = await process.exitCode;
    final stdOut = (await stdOutFuture).join();
    final stdErr = (await stdErrFuture).join();

    return io.ProcessResult(
      process.pid,
      exitCode,
      stdOut,
      stdErr,
    );
  }
}

class _ProcessParams {
  final String exe;
  final List<String> args;

  _ProcessParams(this.exe, this.args);
}
