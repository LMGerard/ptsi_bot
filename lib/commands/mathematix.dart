import 'dart:async';
import 'package:html/dom.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class Mathematix extends Command with HasMultiSelect {
  static Map<String, dynamic>? tree;
  Mathematix() : super("ronan", "Access mathematics courses.", []);

  static const url = 'http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html';
  static const dlUrl = 'http://ronan.lauvergnat.fr/Enseignement/2021-2022/';

  @override
  Future execute(event) async {
    await updateTree();

    final options = tree!.keys.map((e) => MultiselectOptionBuilder(e, e));
    final row = ComponentRowBuilder()
      ..addComponent(
        MultiselectBuilder('Ronan0', options),
      );

    sendEmbed<EMBED_RESPOND>(
      event,
      text: 'Choisis le document à télécharger :',
      componentRowBuilders: [row],
    );
  }

  Iterable<List<String>> treeQuery(Iterable<List<String>> paths, String path) {
    final query =
        paths.where((e) => e.first == path).map((e) => e..removeAt(0));
    return query;
  }

  @override
  Map<String, Function(IMultiselectInteractionEvent)> get multiSelects => {
        'Ronan0': multiselectHandler,
      };

  Future<void> multiselectHandler(IMultiselectInteractionEvent event) async {
    await event.acknowledge();
    if (tree == null) return;
    final choice = event.interaction.values.first;

    if (choice.endsWith('.pdf')) {
      final k = await http.readBytes(Uri.parse(
          dlUrl + choice.replaceFirst('Enseignement/2021-2022/', '')));

      sendEmbed<EMBED_RESPOND>(
        event,
        text: 'Et voici ton document !',
        attachment: AttachmentBuilder.bytes(k, choice.replaceAll('/', '_')),
      );
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

    sendEmbed<EMBED_EDIT_RESPONSE>(event, componentRowBuilders: [row]);
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
    final res = await http.get(Uri.parse(Mathematix.url));

    final parsed = parse(res.body); // Parse html body

    final tree = <String, dynamic>{}; // Create tree to fill
    // Get summary section
    final summary = parsed.querySelectorAll('.masection ul li a[href]');
    final reg = RegExp('#.*');
    // Iterate over summary
    for (final i in summary) {
      final uid = reg
          .firstMatch(i.attributes['href']!)!
          .group(0)!
          .replaceFirst('#', '');

      String str = "[id=\"$uid\"] + p";
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
        tree[uid.replaceFirst('#', '')] = result;
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

        tree[uid.replaceFirst('#', '')] = result;
      }
    }

    Mathematix.tree = tree;
  }
}
