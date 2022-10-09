import 'dart:io';
import 'package:path/path.dart' as path;

Future<void> scanAndChangeRepos(String repoText) async {
  await for (final i in scanForFiles(
    root: Directory.current,
    namePattern: RegExp(r'\.gradle$'),
  )) {
    await setRepo(i, repoText);
  }
}

Stream<File> scanForFiles({
  required Directory root,
  required Pattern namePattern,
}) async* {
  yield* root.list(recursive: true).where(
    (event) {
      return event is File;
    },
  ).where(
    (event) {
      return path.basename(event.path).contains(namePattern);
    },
  ).map<File>(
    (event) {
      if (event is File) {
        print('found ${event.path}');
        return event;
      }
      throw Exception('event is not a file actually its impossible');
    },
  );
}

Future<void> setRepo(File sourceFile, String repoAddress) async {
  final oldValue = sourceFile.readAsStringSync();
  final repoStartingPoint = RegExp(r'repositories\s*{');
  if (!oldValue.contains(repoStartingPoint)) {
    print('cannot find any repository entry in `${sourceFile.path}` <it isn\'t an error>');
  } else if (oldValue.contains(repoAddress)) {
    print('repo already existed in `${sourceFile.path}`');
  } else {
    final newVal = oldValue.replaceAll(repoStartingPoint, '''
repositories { 
$repoAddress''');
    sourceFile.writeAsStringSync(newVal);
    print('repo added to `${sourceFile.path}`');
  }
}
