import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:nyxx/nyxx.dart';

class Cli {
  static late INyxxWebsocket bot;
  static IGuild? connectedGuild;
  static ITextGuildChannel? connectedChannel;

  static Map<String, void Function(List<String>)> cliCommands = {
    'guild': Cli.__guild,
    'channel': Cli.__channel,
    'say': Cli.__say,
    'help': Cli.__help,
  };

  static void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  static void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static Future<String> start(INyxxWebsocket bot) async {
    Cli.bot = bot;

    bot.eventsWs.onMessageReceived.forEach((event) {
      if (event.message.channel.id == connectedChannel?.id) {
        Cli.printWarning(
          '${event.message.author.username}: ${event.message.content}',
        );
      }
    });

    final c = Completer<String>(); // completer
    final l = stdin // stdin
        .transform(utf8.decoder) // decode
        .transform(const LineSplitter()) // split line
        .asBroadcastStream() // make it stream
        .listen((line) {
      if (line.isEmpty) return;
      final args = line.split(' ');

      final command = args.removeAt(0);

      if (cliCommands.containsKey(command)) {
        cliCommands[command]!(args);
      } else {
        printError('Command not found');
      }
    });
    final o = await c.future; // get output from future
    l.cancel(); // cancel stream after future is completed
    return o;
  }

  static void __help(List<String> args) {
    printWarning(
      'Available commands:\n'
      ' guild <guild index>\n'
      ' channel <channel index>\n'
      ' say <message>\n',
    );
  }

  static void __guild(List<String> args) {
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
  }

  static void __channel(List<String> args) {
    if (connectedGuild == null) {
      printError('Not connected to a guild');
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
        printError('Channel index out of range');
        return;
      }

      connectedChannel = connectedGuild!.channels
          .whereType<ITextGuildChannel>()
          .elementAt(channelIndex);
      printWarning(
        'Connected to ${connectedChannel?.name} from ${connectedGuild!.name}',
      );
    }
  }

  static void __say(List<String> args) {
    if (connectedChannel == null) {
      printError('Not connected to a channel');
      return;
    }

    if (args.isEmpty) {
      printWarning('No message');
      return;
    }

    connectedChannel?.sendMessage(MessageBuilder.content(args.join(' ')));
  }
}
