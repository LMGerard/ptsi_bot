import 'package:nyxx/nyxx.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class Text2emojis extends Command {
  static const ints = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine'
  ];
  Text2emojis() : super('text2emojis', 'text to emojis');

  @override
  Function get execute =>
      (IChatContext context, String sentence, [bool maxSize = false]) async {
        final text = sentence.split('').map((e) {
          if (e == ' ') return ':black_small_square:';
          if (e == '?') return ':question:';
          if (e == '!') return ':exclamation:';

          final isInt = int.tryParse(e);
          if (isInt != null) return ':${ints[isInt]}:';

          return ':regional_indicator_${e.toLowerCase()}:';
        }).join(' ');

        if (maxSize) {
          context.respond(MessageBuilder.content(text));
        } else {
          respond(context, text: text);
        }
      };
}
