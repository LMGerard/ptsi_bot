import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/commands/avatar.dart';
import 'package:ptsi_bot/commands/help.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:ptsi_bot/commands/precision.dart';
import 'package:ptsi_bot/commands/quizz.dart';
import 'package:ptsi_bot/commands/ronan.dart';
import 'package:ptsi_bot/commands/stop.dart';
import 'package:ptsi_bot/commands/test.dart';

final List<SlashCommandBuilder> commands = [
  Stop(),
  Music(),
  Precision(),
  Help(),
  Ronan(),
  Test(),
  Quizz(),
  Avatar(),
];

mixin EMBED_SENDFOLLOWUP {}
mixin EMBED_RESPOND {}
mixin EMBED_SEND {}

abstract class Command extends SlashCommandBuilder with EmbedSupport {
  Command(String name, String? description, List<CommandOptionBuilder> options)
      : super(name, description, options) {
    if (!options.any((e) => e.type == CommandOptionType.subCommand)) {
      registerHandler(execute);
    }
  }

  FutureOr execute(ISlashCommandInteractionEvent event);
}

abstract class SubCommand extends CommandOptionBuilder with EmbedSupport {
  SubCommand(String name, String description,
      {List<CommandOptionBuilder>? options})
      : super(CommandOptionType.subCommand, name, description,
            options: options) {
    registerHandler(execute);
  }

  FutureOr execute(ISlashCommandInteractionEvent event);
}

mixin HasMultiSelect {
  Map<String, Function(IMultiselectInteractionEvent p1)> get multiSelects;
}

mixin HasButton {
  Map<String, Function(IButtonInteractionEvent p1)> get buttons;
}

mixin EmbedSupport {
  Future<void> sendEmbed<T>(IInteractionEventWithAcknowledge event,
      {String text = '', AttachmentBuilder? attachment}) async {
    final embed = createEmbed(text: text);
    final msg = MessageBuilder.embed(embed);
    if (attachment != null) msg.addAttachment(attachment);
    final channel = await event.interaction.channel.getOrDownload();

    switch (T) {
      case EMBED_RESPOND:
        event.respond(msg);
        break;
      case EMBED_SENDFOLLOWUP:
        event.sendFollowup(msg);
        break;
      case EMBED_SEND:
        channel.sendMessage(msg);
        break;
      default:
        event.respond(msg);
        break;
    }
  }

  EmbedBuilder createEmbed({String text = '', AttachmentBuilder? attachment}) {
    return EmbedBuilder()
      ..title = runtimeType.toString()
      ..description = text
      ..color = DiscordColor.fromInt(3447003);
  }
}
