import 'dart:async';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'command.dart';

class Test extends Command {
  final url =
      Uri.parse('http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html');

  Test() : super('test', 'A test command', []);

  @override
  FutureOr execute(event) async {
    event.acknowledge();
    //p a.doc[href^="Enseignement"]
    final res = await http.get(url);

    final parsed = parse(res.body);
    final tree = {};
    final summary = parsed.querySelectorAll('.masection ul li a');
    final reg = RegExp('#.*');
    for (final i in summary.where((e) => e.attributes.containsKey('href'))) {
      final id = reg.firstMatch(i.attributes['href']!)!.group(0)!;
      final ps = parsed
          .querySelectorAll('$id ~ *')
          .takeWhile((e) => e.innerHtml.contains('.pdf'));

      if (ps.isEmpty) continue;

      if (ps.length == 1) {
        final result = ps.first.children
            .where((e) => e.attributes.containsKey('href'))
            .map((e) => e.attributes['href']!);
        tree[id.replaceFirst('#', '')] = result;
      } else {
        final result = <String, Iterable<String>>{};

        for (final i in ps) {
          final name = i.children.first.text.replaceAll(RegExp('[0-9].*'), '');
          result[name] = i.children
              .where((e) => e.attributes.containsKey('href'))
              .map((e) => e.attributes['href']!
                  .replaceFirst('Enseignement/2021-2022/', ''));
        }

        tree[id.replaceFirst('#', '')] = result;
      }

      print(tree);
    }
  }

  void test() async {}
}
