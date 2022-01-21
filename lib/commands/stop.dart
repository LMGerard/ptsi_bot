import 'dart:async';
import 'command.dart';

class Stop extends Command {
  Stop() : super("stop", "Stops the bot", []);

  @override
  FutureOr execute(event) {
    sendEmbed<EMBED_RESPOND>(event, text: 'Bot stopped !');
  }
}
