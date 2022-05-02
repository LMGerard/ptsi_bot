import 'dart:async';
import 'command.dart';

class Stop extends Command {
  Stop() : super("stop", "Stops the bot", []);

  @override
  Future execute(event) {
    return sendEmbed<EMBED_RESPOND>(event, text: 'Bot stopped !');
  }
}
