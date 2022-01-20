import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'command.dart';

class Stop extends Command {
  Stop() : super("stop", "Stops the bot", []);

  @override
  FutureOr execute(event) {
    event.respond(MessageBuilder.content('Bot stopped !'));
  }
}
