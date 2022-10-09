import 'package:repo_manager/repo_manager.dart' as repo_manager;

const newMev = "maven { url 'https://gradle.iranrepo.ir' }";
void main(List<String> arguments) async {
  final newRepo = arguments.isNotEmpty ? arguments.first : newMev;
  await repo_manager.scanAndChangeRepos(newRepo);
}
