import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'command.dart';

class Stop extends SingleCommand {
  @override
  String get name => 'stop';
  @override
  String get description => 'Stop the bot.';

  @override
  FutureOr execute(event) {
    event.respond(MessageBuilder.content('Bot stopped !'));
  }
}
