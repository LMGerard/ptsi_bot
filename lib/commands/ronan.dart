import 'dart:async';
import 'package:html/dom.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class Ronan extends Command with HasMultiSelect {
  static Map<String, dynamic>? tree;
  Ronan() : super("ronan", "Access mathematics courses.", []);

  static const url = 'http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html';
  static const dlUrl = 'http://ronan.lauvergnat.fr/Enseignement/2021-2022/';

  @override
  FutureOr execute(event) async {
    await updateTree();

    final options = tree!.keys.map((e) => MultiselectOptionBuilder(e, e));

    await event.respond(
      ComponentMessageBuilder()
        ..content = "Choisis le document à télécharger :"
        ..addComponentRow(ComponentRowBuilder()
          ..addComponent(MultiselectBuilder('Ronan0', options))),
    );
  }

  Iterable<List<String>> treeQuery(Iterable<List<String>> paths, String path) {
    final query =
        paths.where((e) => e.first == path).map((e) => e..removeAt(0));
    return query;
  }

  @override
  Map<String, Function(IMultiselectInteractionEvent)> get multiSelects => {
        'Ronan0': multiselectHandlerHandler,
      };

  static Future<void> multiselectHandlerHandler(
      IMultiselectInteractionEvent event) async {
    await event.acknowledge();
    if (tree == null) return;
    final choice = event.interaction.values.first;

    if (choice.endsWith('.pdf')) {
      final k = await http.readBytes(Uri.parse(
          dlUrl + choice.replaceFirst('Enseignement/2021-2022/', '')));

      final b = ComponentMessageBuilder()
        ..files = [AttachmentBuilder.bytes(k, choice.replaceAll('/', '_'))];
      await event.respond(b..content = 'Et voici ton document !');
      return;
    }

    final options = getTree(choice);

    final ms = MultiselectBuilder('Ronan0');
    final row = ComponentRowBuilder()..addComponent(ms);

    for (String option in options) {
      if (option.contains('.pdf')) {
        ms.addOption(MultiselectOptionBuilder(option, option));
      } else {
        ms.addOption(
          MultiselectOptionBuilder("$choice/$option", "$choice/$option"),
        );
      }
    }
    event.editOriginalResponse(
      ComponentMessageBuilder()..addComponentRow(row),
    );
  }

  static Iterable<String> getTree(String choice) {
    Map current = tree!;
    for (final e in choice.split('/')) {
      final cur = current[e];
      if (cur is Map) {
        current = cur;
        continue;
      }
      return cur as Iterable<String>;
    }
    return current.keys as Iterable<String>;
  }

  static Future updateTree() async {
    final res = await http.get(Uri.parse(Ronan.url));

    final parsed = parse(res.body); // Parse html body

    final tree = <String, dynamic>{}; // Create tree to fill
    // Get summary section
    final summary = parsed.querySelectorAll('.masection ul li a');
    final reg = RegExp('#.*');
    // Iterate over summary
    for (final i in summary.where((e) => e.attributes.containsKey('href'))) {
      final id = reg
          .firstMatch(i.attributes['href']!)!
          .group(0)!
          .replaceFirst('#', '');

      String str = "[id=\"$id\"] + p";
      final elements = <Element>[];
      while (true) {
        final e = parsed.querySelector(str);
        if (e == null) {
          break;
        } else {
          elements.add(e);
          str = "$str + p";
        }
      }

      if (elements.isEmpty) continue;

      if (elements.length == 1) {
        // Only 1 child => add pdfs list
        final result = elements.first.children
            .where((e) => e.attributes.containsKey('href'))
            .map((e) => e.attributes['href']!);
        tree[id.replaceFirst('#', '')] = result;
      } else {
        // Multiple children => add tree branch
        final result = <String, Iterable<String>>{};

        for (final i in elements) {
          final name = i.children.first.text.replaceAll(RegExp('[0-9].*'), '');
          result[name] = i.children
              .where((e) => e.attributes.containsKey('href'))
              .map((e) => e.attributes['href']!
                  .replaceFirst('Enseignement/2021-2022/', ''));
        }

        tree[id.replaceFirst('#', '')] = result;
      }
    }

    Ronan.tree = tree;
  }
}
