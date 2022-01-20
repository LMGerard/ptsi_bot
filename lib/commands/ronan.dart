import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

import 'command.dart';
import 'package:http/http.dart' as http;

class Ronan extends Command {
  Ronan() : super("ronan", "Access mathematics courses.", []);

  final url =
      Uri.parse('http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html');

  @override
  String get name => 'ronan';
  @override
  String get description => '42';

  @override
  FutureOr execute(event) async {
    final response = await http.get(url);
    final matches = RegExp("[^\"]*.pdf").allMatches(response.body);

    final urls = matches.map(
      (match) => response.body
          .substring(match.start, match.end)
          .replaceFirst(RegExp('.*/2021-2022/'), '')
          .split('/'),
    );

    final componentMessageBuilder = ComponentMessageBuilder();
    componentMessageBuilder.content = "Try some of the components below!";
    final options = Set.from(urls.map((e) => e.first))
        .map((e) => MultiselectOptionBuilder(e, e));
    final first = ComponentRowBuilder()
      ..addComponent(MultiselectBuilder("Ronan1", options));

    componentMessageBuilder.addComponentRow(first);

    await event.respond(componentMessageBuilder);
  }

  Iterable<List<String>> treeQuery(Iterable<List<String>> paths, String path) {
    final query =
        paths.where((e) => e.first == path).map((e) => e..removeAt(0));
    return query;
  }

  @override
  Map<String, Function(IMultiselectInteractionEvent p1)> get multiSelects =>
      {'Ronan1': multiselectHandlerHandler};

  Future<void> multiselectHandlerHandler(
      IMultiselectInteractionEvent event) async {
    await event.acknowledge();
    await event.sendFollowup(
      MessageBuilder.content(
          "Option chosen with values: ${event.interaction.values}"),
    );
  }
}
