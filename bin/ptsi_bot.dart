import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:ptsi_bot_2/commands/music.dart';
import 'package:ptsi_bot_2/settings.dart' as settings;
import 'package:ptsi_bot_2/cli/cli.dart';

void main(List<String> arguments) {
  final commandsPlugin = CommandsPlugin(prefix: (e) => settings.prefix);

  final bot = NyxxFactory.createNyxxWebsocket(
    settings.token,
    GatewayIntents.all,
  );

  bot
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..registerPlugin(commandsPlugin)
    ..connect();

  bot.onReady.first.then(
    (value) {
      Music.init(bot);
    },
  );

  Cli.start(bot);

  for (final command in commands) {
    command.register(commandsPlugin);
  }
}
