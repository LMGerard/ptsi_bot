import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:nyxx/nyxx.dart';

const TOKEN = "OTAxNzgzNzIzMTEwOTY1MzE4.YXU5iQ.JUiGtUC5YuEbIZPRa0uN9BqLg5c";
const TOKENUSELESS =
    "ODAyNjk0MTk3NDYyODI3MDE5.YAy9Og.5UlqjgRPlBSg7tNXD8oTy_AeJLI";

void main() {
  final bot = NyxxFactory.createNyxxWebsocket(TOKEN, GatewayIntents.all);
  bot
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();

  Cli.start(bot);
}

class Cli {
  static List<int> hiddens = [];
  static late INyxxWebsocket bot;
  static IGuild? connectedGuild;
  static ITextGuildChannel? connectedChannel;
  static IVoiceGuildChannel? connectedVoiceChannel;

  static Map<String, void Function(List<String>)> cliCommands = {
    'guild': Cli.__guild,
    'channel': Cli.__channel,
    'write': Cli.__write,
    'read': Cli.__read,
    'help': Cli.__help,
    'voice': Cli.__voice,
    'hide': Cli.__hide,
  };

  static void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  static void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void printMessage(IMessage message) {
    printWarning(
        '${message.createdAt}  ${message.author.username}: ${message.content}');
  }

  static Future<String> start(INyxxWebsocket bot) async {
    Cli.bot = bot;

    bot.eventsWs.onMessageReceived.forEach((event) {
      if (event.message.channel.id == connectedChannel?.id) {
        printMessage(event.message);
      }
    });

    bot.eventsWs.onMessageReactionAdded.forEach((event) {
      print(event.emoji);
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

  static void __voice(List<String> args) {
    if (connectedGuild == null) {
      printError('Not connected to a guild');
      return;
    }

    if (args.isEmpty || int.tryParse(args.first) == null) {
      final channels = connectedGuild!.channels.whereType<IVoiceGuildChannel>();

      print(
        List.generate(
          channels.length,
          (index) => '$index: ${channels.elementAt(index).name}',
        ),
      );

      connectedVoiceChannel?.disconnect();
    } else {
      connectedVoiceChannel = connectedGuild!.channels
          .whereType<IVoiceGuildChannel>()
          .elementAt(int.parse(args.first));

      connectedVoiceChannel?.connect();
    }
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

  static void __write(List<String> args) {
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

  static void __read(List<String> args) {
    if (connectedChannel == null) {
      printError('Not connected to a channel');
      return;
    }

    if (args.isEmpty || int.tryParse(args.first) == null) {
      printWarning('Invalid number');
      return;
    }

    connectedChannel!
        .downloadMessages(limit: int.parse(args.first))
        .forEach(printMessage);
  }

  static void __hide(List<String> args) {
    if (args.isEmpty) {
      print('0: LMG \n 1: AB');
      return;
    }
    if (int.tryParse(args.first) == null) {
      printError('Invalid id');
      return;
    }
    int id = int.parse(args.first);

    if (id == 0) {
      id = 371298344921726978;
    } else if (id == 1) {
      id = 688470658728198222;
    }

    if (hiddens.contains(id)) {
      hiddens.remove(id);
      printWarning('$id is now visible');
    } else {
      hiddens.add(id);
      printWarning('$id is now hidden');
    }
  }
}
