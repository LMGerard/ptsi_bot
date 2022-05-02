import 'dart:async';
import 'dart:math';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';

class Pgcd extends Command {
  Pgcd()
      : super('pgcd', 'Calculate the pgcd', [
          CommandOptionBuilder(
            CommandOptionType.integer,
            'integer1',
            'integer 1',
            required: true,
          ),
          CommandOptionBuilder(
            CommandOptionType.integer,
            'integer2',
            'integer 2',
            required: true,
          ),
        ]);

  @override
  Future execute(ISlashCommandInteractionEvent event) async {
    final int1 = event.args.first.value as int;
    final int2 = event.args.last.value as int;

    List<int> step = [max(int1, int2), min(int1, int2)];

    String result = '';
    do {
      step = [step.last, step.first, step.first % step.last];
      result +=
          '${step[1]} = ${step[0]} * ${step[1] ~/ step[0]} + ${step.last}\n';
    } while (step.last != 0);

    result += '\nPGCD($int1, $int2) = ${step.first}\n';
    result += '\nPPCM($int1, $int2) = ${int1 * int2 ~/ step.first}';

    sendEmbed<EMBED_RESPOND>(event, text: result);
  }
}
