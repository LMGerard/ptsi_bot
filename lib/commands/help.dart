import 'package:nyxx_interactions/nyxx_interactions.dart';

import 'command.dart';
import 'dart:async';

class Help extends Command {
  Help()
      : super('help', 'As much help as you need', [
          CommandOptionBuilder(
            CommandOptionType.string,
            'command',
            'command',
            choices: commands
                .map(
                  (e) => ArgChoiceBuilder(e.name, e.name),
                )
                .toList(),
          )
        ]);

  @override
  Future execute(event) {
    if (event.args.isEmpty) {
      String text =
          commands.map((e) => "__${e.name}__ - ${e.description}").join('\n');

      return sendEmbed<EMBED_RESPOND>(event, text: text);
    } else {
      final commandName = event.getArg('command').value as String;
      final command = commands.firstWhere((e) => e.name == commandName);

      String text = "\n__Description:__\n${command.description}";

      for (final opt in command.options) {
        text += optionHelp(opt);
      }
      return sendEmbed<EMBED_RESPOND>(event,
          title: ' - ${command.name}', text: text);
    }
  }

  String optionHelp(CommandOptionBuilder option) {
    String text = "\n\n**${option.name}** - ${option.description}";

    final options = option.options?.map((e) => optionHelp(e)).join('\t');

    text += (options != null) ? '\n__options:__ $options' : '';
    final choices = option.choices?.map((e) => e.name).join(', ');
    text += (choices != null) ? '\n__args:__ $choices' : '';

    return text;
  }
}
