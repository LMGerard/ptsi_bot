import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/commands/help.dart';
import 'package:ptsi_bot/commands/music.dart';
import 'package:ptsi_bot/commands/precision.dart';
import 'package:ptsi_bot/commands/stop.dart';

final List<Command> commands = [
  Stop(),
  Music(),
  Precision(),
  Help(),
];

abstract class Command {
  String get name;
  String get description;

  static register(Command command, IInteractions interactions) {
    interactions.registerSlashCommand(command.buildCommand());
  }

  SlashCommandBuilder buildCommand();

  Future<void> respond(ISlashCommandInteractionEvent event,
      {String text = ''}) {
    return event.respond(MessageBuilder.content(
      "**$name:**\n\n" + text,
    ));
  }
}

abstract class SingleCommand extends Command {
  FutureOr execute(ISlashCommandInteractionEvent event);

  @override
  SlashCommandBuilder buildCommand() {
    return SlashCommandBuilder(
      name,
      description,
      [],
    )..registerHandler(execute);
  }
}

abstract class MultiCommand extends Command {
  List<SubCommand> get subCommands;

  @override
  SlashCommandBuilder buildCommand() {
    return SlashCommandBuilder(
      name,
      description,
      subCommands.map((e) => e.buildCommand()).toList(),
    );
  }
}

abstract class SubCommand {
  String get name;
  List<SubCommand> get subCommands;
  List<CommandOptionBuilder> get args;

  FutureOr execute(ISlashCommandInteractionEvent event);

  CommandOptionBuilder buildCommand() {
    return CommandOptionBuilder(
      CommandOptionType.subCommand,
      name,
      'description',
      options: args,
    )..registerHandler(execute);
  }
}
