import 'command.dart';
import 'package:nyxx/nyxx.dart';
import 'dart:async';
import 'command.dart';

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
