import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/commands/help.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:ptsi_bot/commands/precision.dart';
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
];

abstract class Command extends SlashCommandBuilder {
  Command(String name, String? description, List<CommandOptionBuilder> options)
      : super(name, description, options) {
    if (options.isEmpty) registerHandler(execute);
  }

  FutureOr execute(ISlashCommandInteractionEvent event);

  Future<void> respond(ISlashCommandInteractionEvent event,
      {String text = ''}) {
    return event.respond(MessageBuilder.content(
      "**$name:**\n\n" + text,
    ));
  }
}

abstract class SubCommand extends CommandOptionBuilder {
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
