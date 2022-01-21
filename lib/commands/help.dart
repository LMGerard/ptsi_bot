import 'command.dart';
import 'dart:async';

class Help extends Command {
  Help() : super('help', 'As much help as you need', []);

  @override
  FutureOr execute(event) {
    String text =
        commands.map((e) => "__${e.name}__ - ${e.description}").join('\n');

    return sendEmbed<EMBED_RESPOND>(event, text: text);
  }
}
