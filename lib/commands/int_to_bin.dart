import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class IntToBin extends Command {
  IntToBin() : super('binary', 'Convert a decimal number to binary.');

  @override
  Function get execute => (IChatContext context, int number) async {
        final r = _toBin(number);

        respond(
          context,
          text:
              "Base 10:\n    ``$number``\nBase 2:\n   ``${r.result}``\n\n||${r.steps.join('\n')}||",
        );
      };

  _ResultAndSteps _toBin(int number) {
    var binary = '';
    final steps = <String>[];
    int step = number;
    while (step > 0) {
      steps.add("$step = ${step ~/ 2} * 2 + ${step % 2}");
      binary = "${step % 2}$binary";
      step = step ~/ 2;
    }
    return _ResultAndSteps(binary, steps);
  }

  // _ResultAndSteps _complementA2(int number) {
  //   final a = (number.abs() + 1).toRadixString(2);
  // }
}

class _ResultAndSteps {
  final String result;
  final List<String> steps;

  _ResultAndSteps(this.result, this.steps);
}
