import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:ptsi_bot/commands/command.dart';
import 'package:ptsi_bot/commands/help.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/commands/test.dart';
import 'package:test/expect.dart';

const TOKEN = "OTAxNzgzNzIzMTEwOTY1MzE4.YXU5iQ.JUiGtUC5YuEbIZPRa0uN9BqLg5c";
const TOKENUSELESS =
    "ODAyNjk0MTk3NDYyODI3MDE5.YAy9Og.5UlqjgRPlBSg7tNXD8oTy_AeJLI";

final bot = NyxxFactory.createNyxxWebsocket(TOKENUSELESS, GatewayIntents.all);
void main(List<String> arguments) async {
  print(arguments);
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
  commands.add(Help()); // Conflict issues because it accesses commands list
  for (final command in commands) {
    // final perms = command.perm;
    // if (perms > 0) {
    //   final guilds = bot.guilds.values;
    //   for (var guild in guilds) {
    //     for (final role in guild.roles.values) {
    //       if (role.permissions.hasPermission(perms)) {
    //         command.addPermission(RoleCommandPermissionBuilder(role.id));
    //       }
    //     }
    //   }
    // }
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
