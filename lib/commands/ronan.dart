import 'dart:async';
import 'dart:math';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class Ronan extends Command with HasMultiSelect {
  Map<String, dynamic>? tree;
  Ronan() : super("ronan", "Access mathematics courses.", []);

  final url = 'http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html';
  final dlUrl = 'http://ronan.lauvergnat.fr/Enseignement/2021-2022/';

  @override
  FutureOr execute(event) async {
    final response = await http.get(Uri.parse(url));
    tree = genTree(response);

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
        'Ronan1': multiselectHandlerHandler,
        'Ronan2': multiselectHandlerHandler,
        'Ronan3': multiselectHandlerHandler,
        'Ronan4': multiselectHandlerHandler,
        'Ronan5': multiselectHandlerHandler,
      };

  Future<void> multiselectHandlerHandler(
      IMultiselectInteractionEvent event) async {
    await event.acknowledge();
    if (tree == null) return;
    final choice = event.interaction.values.first;

    if (choice.endsWith('.pdf')) {
      final k = await http.readBytes(Uri.parse(dlUrl + choice));

      event.sendFollowup(MessageBuilder.files(
        [AttachmentBuilder.bytes(k, choice.replaceAll('/', '_'))],
      )..content = 'Et voici ton document !');
      return;
    }
    final options = tree![choice.split('/').last];
    final ms = MultiselectBuilder('Ronan1');
    final row = ComponentRowBuilder()..addComponent(ms);

    if (options is Iterable<String>) {
      for (final option in options) {
        ms.addOption(MultiselectOptionBuilder(option, option));
      }
      event.editOriginalResponse(
        ComponentMessageBuilder()..addComponentRow(row),
      );
      return;
    }

    if (options is Map<String, dynamic>) {
      tree = options;
      for (final option in options.keys) {
        ms.addOption(
          MultiselectOptionBuilder("$choice/$option", "$choice/$option"),
        );
      }
      event.editOriginalResponse(
        ComponentMessageBuilder()..addComponentRow(row),
      );
      return;
    }
  }

  Map<String, dynamic> genTree(http.Response res) {
    final parsed = parse(res.body); // Parse html body

    final tree = <String, dynamic>{}; // Create tree to fill
    // Get summary section
    final summary = parsed.querySelectorAll('.masection ul li a');
    final reg = RegExp('#.*');
    // Iterate over summary
    for (final i in summary.where((e) => e.attributes.containsKey('href'))) {
      final id = reg.firstMatch(i.attributes['href']!)!.group(0)!;
      final ps = parsed
          .querySelectorAll('$id ~ *')
          .takeWhile((e) => e.innerHtml.contains('.pdf'));

      if (ps.isEmpty) continue;

      if (ps.length == 1) {
        // Only 1 child => add pdfs list
        final result = ps.first.children
            .where((e) => e.attributes.containsKey('href'))
            .map((e) => e.attributes['href']!);
        tree[id.replaceFirst('#', '')] = result;
      } else {
        // Multiple children => add tree branch
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
    }
    return tree;
  }
}
