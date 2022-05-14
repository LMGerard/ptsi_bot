import 'dart:math';

import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class PGCD extends Command {
  PGCD() : super('pgcd', 'Calcule le PGCD de deux nombres.');

  @override
  Function get execute => (IChatContext context, int num1, int num2) async {
        List<int> step = [max(num1, num2), min(num1, num2)];

        String result = '';
        do {
          step = [step.last, step.first, step.first % step.last];
          result +=
              '${step[1]} = ${step[0]} * ${step[1] ~/ step[0]} + ${step.last}\n';
        } while (step.last != 0);

        result += '\nPGCD($num1, $num2) = ${step.first}\n';
        result += '\nPPCM($num1, $num2) = ${num1 * num2 ~/ step.first}';

        respond(context, text: result);
      };
}
