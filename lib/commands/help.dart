import 'command.dart';
import 'dart:async';

class Help extends SingleCommand {
  @override
  String get name => 'help';
  @override
  String get description => 'As much help as you need';

  @override
  FutureOr execute(event) {
    String text =
        commands.map((e) => "${e.name} - ${e.description}").join('\n');

    return respond(event, text: text);
  }
}
