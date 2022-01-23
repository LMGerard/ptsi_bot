import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:ptsi_bot/commands/command.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/commands/test.dart';

const TOKEN = "OTAxNzgzNzIzMTEwOTY1MzE4.YXU5iQ.JUiGtUC5YuEbIZPRa0uN9BqLg5c";
const TOKENUSELESS =
    "ODAyNjk0MTk3NDYyODI3MDE5.YAy9Og.5UlqjgRPlBSg7tNXD8oTy_AeJLI";

final bot = NyxxFactory.createNyxxWebsocket(TOKENUSELESS, GatewayIntents.all);
void main(List<String> arguments) async {
  bot
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();

  bot.onReady.first.then(
    (value) {
      Music.cluster = ICluster.createCluster(bot, bot.appId);
      Music.cluster.addNode(
        NodeOptions(
          host: 'lava.link',
          port: 80,
          password: "password",
          ssl: false,
        ),
      );
    },
  );

  final interactions = IInteractions.create(WebsocketInteractionBackend(bot));

  for (final command in commands) {
    interactions.registerSlashCommand(command);

    if (command is HasMultiSelect) {
      (command as HasMultiSelect).multiSelects.forEach((key, value) {
        interactions.registerMultiselectHandler(key, value);
      });
    }
    if (command is HasButton) {
      (command as HasButton).buttons.forEach((key, value) {
        interactions.registerButtonHandler(key, value);
      });
    }
  }

  interactions.syncOnReady();
}
