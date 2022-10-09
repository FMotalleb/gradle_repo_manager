import 'package:gradle_repo_manager/gradle_repo_manager.dart' as gradle_repo_manager;

const newMev = "maven { url 'https://gradle.iranrepo.ir' }";
void main(List<String> arguments) async {
  final newRepo = arguments.isNotEmpty ? arguments.first : newMev;
  await gradle_repo_manager.scanAndChangeRepos(newRepo);
}
