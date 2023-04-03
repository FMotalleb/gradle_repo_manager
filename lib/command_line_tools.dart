import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cli_util/cli_logging.dart';

final HemTerminal cli = HemTerminal._();

class HemTerminal {
  Logger _logger = Logger.standard();
  Duration? get elapsedTime {
    if (_logger is VerboseLoggerCustom) {
      return (_logger as VerboseLoggerCustom).timer;
    } else {
      return null;
    }
  }

  HemTerminal._();
  void useVerbosLogger() {
    _logger = VerboseLoggerCustom();
    printToConsole('using verbose logger config');
  }

  void printToConsole(String message, {bool isError = false}) =>
      isError ? _logger.stderr(message) : _logger.stdout(message);

  String readLineFromConsole() => io.stdin.readLineSync() ?? '';
  Future<T> runAsyncOn<T>(
    String message,
    Future<T> Function(Progress progress) action,
  ) async {
    final progress = _logger.progress(message);

    final result = await action(progress);
    progress.finish(message: 'Done', showTiming: true);
    return result;
  }

  void setVerbose(bool state) {
    _isVerbose = state;
  }

  bool _isVerbose = false;
  void verbosePrint(String message, {bool isError = false}) =>
      _isVerbose ? printToConsole(message, isError: isError) : null;
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
  }) async {
    verbosePrint('running os task $name: $command ${arguments.join(' ')}');

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
        cli.verbosePrint(
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
        cli.verbosePrint(
          newVal,
          isError: true,
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
    verbosePrint(
      '''
exit code: $exitCode

result:
$stdOut

error:
$stdErr

''',
    );
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

class VerboseLoggerCustom implements Logger {
  @override
  Ansi ansi;
  bool logTime;
  final _timer = Stopwatch()..start();
  Duration get timer => _timer.elapsed;
  VerboseLoggerCustom({
    Ansi? ansi,
    this.logTime = false,
  }) : ansi = ansi ??
            Ansi(
              Ansi.terminalSupportsAnsi,
            );

  @override
  bool get isVerbose => true;

  @override
  void stdout(String message) {
    io.stdout.writeln('${_createPrefix()}$message');
  }

  @override
  void stderr(String message) {
    io.stderr.writeln('${_createPrefix()}${ansi.red}$message${ansi.none}');
  }

  @override
  void trace(String message) {
    io.stdout.writeln('${_createPrefix()}${ansi.gray}$message${ansi.none}');
  }

  @override
  void write(String message) {
    io.stdout.write(message);
  }

  @override
  void writeCharCode(int charCode) {
    io.stdout.writeCharCode(charCode);
  }

  @override
  Progress progress(String message) => SimpleProgress(this, message);

  @override
  @Deprecated('This method will be removed in the future')
  void flush() {}

  String _createPrefix() {
    if (!logTime) {
      return '';
    }

    var seconds = _timer.elapsedMilliseconds / 1000.0;
    var minutes = seconds ~/ 60;
    seconds -= minutes * 60.0;

    var buf = StringBuffer();
    if (minutes > 0) {
      buf.write((minutes % 60));
      buf.write('m ');
    }

    buf.write(seconds.toStringAsFixed(3).padLeft(minutes > 0 ? 6 : 1, '0'));
    buf.write('s');

    return '[${buf.toString().padLeft(11)}] ';
  }
}
