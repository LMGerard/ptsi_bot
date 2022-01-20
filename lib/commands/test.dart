import 'dart:async';
import 'command.dart';
import 'package:http/http.dart' as http;

class Test extends Command {
  final url =
      Uri.parse('http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html');

  Test() : super('test', 'A test command', []);

  @override
  FutureOr execute(event) async {
    final response = await http.get(url);
    print(response.body);
  }

  void test() async {
    final response = await http.get(url);

    final matches = RegExp("[^\"]*.pdf").allMatches(response.body);

    final urls = matches.map(
      (match) => response.body
          .substring(match.start, match.end)
          .replaceFirst(RegExp('.*/2021-2022/'), '')
          .split('/'),
    );

    print(urls);
    print(treeQuery(urls, 'Chap'));
  }

  Iterable<List<String>> treeQuery(Iterable<List<String>> paths, String path) {
    final query =
        paths.where((e) => e.first == path).map((e) => e..removeAt(0));
    return query;
  }
}
