import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart' hide parse;
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class Ronan extends Command {
  static Map<String, dynamic>? tree;

  Ronan() : super('mathematix', 'Access mathematics courses.');
  static const url = 'http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html';
  static const dlUrl = 'http://ronan.lauvergnat.fr/Enseignement/2021-2022/';

  @override
  Function get execute => (IChatContext context) async {
        await updateTree();

        final options = tree!.keys.map((e) => MultiselectOptionBuilder(e, e));
        final select = MultiselectBuilder('Ronan0', options);
        final msg = await respond(
          context,
          text: 'Choisis le document à télécharger :',
          multiselect: select,
        );

        final pdf = await ask(context);

        if (pdf == null) {
          msg.delete();
          return;
        }

        final data = await http.readBytes(
          Uri.parse(dlUrl + pdf.replaceFirst('Enseignement/2021-2022/', '')),
        );

        await msg.dispose();

        msg.edit(
          createMessage(
            text: 'Et voici ton document:',
            attachment: AttachmentBuilder.bytes(data, pdf.replaceAll('/', '_')),
          ),
        );
      };

  Future<String?> ask(IChatContext context) async {
    final event = await context
        .getSelection(
          MultiselectBuilder('Ronan0'),
          timeout: Duration(minutes: 1),
        )
        .then<IMultiselectInteractionEvent?>((value) => value)
        .catchError((e) => null);

    if (event == null) {
      return null;
    }

    final result = event.interaction.values.first;

    if (result.endsWith('.pdf')) {
      return result;
    }

    final options = getTree(result);

    final ms = MultiselectBuilder('Ronan0');

    for (String option in options) {
      if (option.contains('.pdf')) {
        ms.addOption(MultiselectOptionBuilder(option, option));
      } else {
        ms.addOption(
          MultiselectOptionBuilder("$result/$option", "$result/$option"),
        );
      }
    }
    await event.editOriginalResponse(
      createMessage(
        text: 'Choisis le document à télécharger :',
        multiselect: ms,
      ),
    );
    return ask(context);
  }

  Iterable<List<String>> treeQuery(Iterable<List<String>> paths, String path) {
    final query =
        paths.where((e) => e.first == path).map((e) => e..removeAt(0));
    return query;
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

    Ronan.tree = tree;
  }
}
