import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:ptsi_bot/commands/command.dart';
import 'package:ptsi_bot/commands/help.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
// ignore: unused_import
import 'package:ptsi_bot/commands/test.dart';

const TOKEN = "OTAxNzgzNzIzMTEwOTY1MzE4.YXU5iQ.JUiGtUC5YuEbIZPRa0uN9BqLg5c";
const TOKENUSELESS =
    "ODAyNjk0MTk3NDYyODI3MDE5.YAy9Og.5UlqjgRPlBSg7tNXD8oTy_AeJLI";

final bot = NyxxFactory.createNyxxWebsocket(TOKEN, GatewayIntents.all);

IGuild? connectedGuild;
ITextGuildChannel? connectedChannel;

void main(List<String> arguments) async {
  readLine();
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

  bot.eventsWs.onMessageReceived.forEach((event) {
    if (event.message.channel.id == connectedChannel?.id) {
      printWarning(
        '${event.message.author.username}: ${event.message.content}',
      );
    }
  });

  final interactions = IInteractions.create(WebsocketInteractionBackend(bot));
  commands.add(Help()); // Conflict issues because it accesses commands list
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

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

Future<String> readLine() async {
  final c = Completer<String>(); // completer
  final l = io.stdin // stdin
      .transform(utf8.decoder) // decode
      .transform(const LineSplitter()) // split line
      .asBroadcastStream() // make it stream
      .listen((line) {
    final args = line.split(' ');

    if (args.isEmpty) return;

    switch (args.removeAt(0)) {
      case 'guild':
        if (args.isEmpty || int.tryParse(args.first) == null) {
          final guilds = bot.guilds.values
              .toList()
              .asMap()
              .entries
              .map((entry) => "${entry.key} ${entry.value.name}")
              .join('\n');

          print(guilds);
        } else {
          final guildIndex = int.parse(args.first);

          if (guildIndex > bot.guilds.length) {
            print('Guild index out of range');
            return;
          }
          connectedGuild = bot.guilds.values.elementAt(guildIndex);
          connectedChannel = null;
          print('Connected to ${connectedGuild!.name}');
        }

        break;
      case 'channel':
        if (connectedGuild == null) {
          print('Not connected to a guild');
          return;
        }

        if (args.isEmpty || int.tryParse(args.first) == null) {
          final channels = connectedGuild!.channels
              .whereType<ITextGuildChannel>()
              .toList()
              .asMap()
              .entries
              .map((entry) => "${entry.key} ${entry.value.name}")
              .join('\n');

          print(channels);
        } else {
          final channelIndex = int.parse(args.first);

          if (channelIndex > connectedGuild!.channels.length) {
            print('Channel index out of range');
            return;
          }

          connectedChannel = connectedGuild!.channels
              .whereType<ITextGuildChannel>()
              .elementAt(channelIndex);
          print(
              'Connected to ${connectedChannel?.name} from ${connectedGuild!.name}');
        }
        break;
      case 'say':
        if (connectedChannel == null) {
          print('Not connected to a channel');
          return;
        }

        if (args.isEmpty) {
          print('No message');
          return;
        }

        connectedChannel?.sendMessage(MessageBuilder.content(args.join(' ')));
        break;
    }
  }); // listen

  final o = await c.future; // get output from future
  l.cancel(); // cancel stream after future is completed
  return o;
}
