import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/commands/avatar.dart';
import 'package:ptsi_bot/commands/liaisons.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:ptsi_bot/commands/precision.dart';
import 'package:ptsi_bot/commands/quizz.dart';
import 'package:ptsi_bot/commands/ronan.dart';
import 'package:ptsi_bot/commands/stop.dart';
import 'package:ptsi_bot/commands/test.dart';
import 'package:ptsi_bot/utils/color.dart';

final List<Command> commands = [
  Stop(),
  Music(),
  Precision(),
  Ronan(),
  Test(),
  Quizz(),
  Avatar(),
  Liaisons(),
];

mixin EMBED_SENDFOLLOWUP {}
mixin EMBED_RESPOND {}
mixin EMBED_SEND {}
mixin EMBED_EDIT_RESPONSE {}

abstract class Command extends SlashCommandBuilder with EmbedSupport {
  Command(String name, String? description, List<CommandOptionBuilder> options)
      : super(name, description, options) {
    if (!options.any((e) =>
        e.type == CommandOptionType.subCommand ||
        e.type == CommandOptionType.subCommandGroup)) {
      registerHandler(execute);
    }
  }

  FutureOr execute(ISlashCommandInteractionEvent event);
}

abstract class SubCommand extends CommandOptionBuilder with EmbedSupport {
  SubCommand(String name, String description,
      {List<CommandOptionBuilder>? options,
      List<ArgChoiceBuilder>? args,
      CommandOptionType type = CommandOptionType.subCommand})
      : super(type, name, description, options: options, choices: args) {
    if (type == CommandOptionType.subCommand ||
        type == CommandOptionType.subCommandGroup) {
      registerHandler(execute);
    }
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
      {String title = '',
      String text = '',
      Iterable<ComponentRowBuilder> componentRowBuilders = const [],
      AttachmentBuilder? attachment}) async {
    final msg = ComponentMessageBuilder()
      ..embeds = [
        createEmbed(title: title, text: text)..imageUrl = attachment?.attachUrl
      ];

    if (componentRowBuilders.isNotEmpty) {
      for (final row in componentRowBuilders.take(5)) {
        msg.addComponentRow(row);
      }
    }
    if (attachment != null) msg.addAttachment(attachment);

    switch (T) {
      case EMBED_RESPOND:
        event.respond(msg);
        break;
      case EMBED_SENDFOLLOWUP:
        event.sendFollowup(msg);
        break;
      case EMBED_SEND:
        final channel = await event.interaction.channel.getOrDownload();
        channel.sendMessage(msg);
        break;
      case EMBED_EDIT_RESPONSE:
        event.editOriginalResponse(msg);
        break;
      default:
        throw Exception(
          'You forgot to specify the type of embed message to send.',
        );
    }
  }

  EmbedBuilder createEmbed(
      {String title = '', String text = '', AttachmentBuilder? attachment}) {
    return EmbedBuilder()
      ..title = runtimeType.toString() + title
      ..description = text
      ..color = themeColor.color;
  }
}
