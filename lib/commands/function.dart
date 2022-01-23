import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'dart:async';
import 'package:image/image.dart';
import 'package:ptsi_bot/commands/command.dart';
import 'package:math_expressions/math_expressions.dart';

class FunctionC extends Command {
  FunctionC()
      : super('function', 'Trace a function', [
          CommandOptionBuilder(
            CommandOptionType.string,
            'function',
            'x**2+3*x+1',
            required: true,
          ),
        ]);

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) {
    final image = Image(500, 500);
    final funcStr = event.getArg('function');
    try {
      final p = Parser().parse(event.getArg('function') as String);
      Variable x = Variable('x'), y = Variable('y');
      ContextModel cm = ContextModel();
      cm.bindVariable(x, Number(2.0));

      print(p.evaluate(EvaluationType.REAL, cm));
    } on StateError {
      event.respond(MessageBuilder.content('Invalid function'));
    }
  }
}
