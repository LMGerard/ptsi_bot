import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:ptsi_bot/commands/command.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

const TOKEN = "OTAxNzgzNzIzMTEwOTY1MzE4.YXU5iQ.JUiGtUC5YuEbIZPRa0uN9BqLg5c";
const TOKENUSELESS =
    "ODAyNjk0MTk3NDYyODI3MDE5.YAy9Og.5UlqjgRPlBSg7tNXD8oTy_AeJLI";
void main(List<String> arguments) async {
  final bot = NyxxFactory.createNyxxWebsocket(TOKENUSELESS, GatewayIntents.all)
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();
  //init Music cluster
  Music.cluster = ICluster.createCluster(bot, Snowflake('802694197462827019'));
  //NodeOptions(host: 'lava.link', port: 80, password: "password", ssl: false);
  await Music.cluster.addNode(
    NodeOptions(host: 'lava.link', port: 80, password: "password", ssl: false),
  );

  final interactions = IInteractions.create(WebsocketInteractionBackend(bot));

  for (final command in commands) {
    Command.register(command, interactions);
  }

  interactions.syncOnReady();
}
