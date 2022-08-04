import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class Test extends Command {
  Test() : super('test', 'A simple test function', converters: [linkConverter]);

  @override
  Function get execute => (IChatContext context, AHAH salut) async {
        respond(context, text: 'Hello world!');
      };
}

final linkConverter = Converter<AHAH>(
  (view, context) {
    final arg = view.getQuotedWord().toLowerCase();
    final t = AHAH.values.where((e) => e.toString().toLowerCase() == arg);
    return t.isEmpty ? null : t.first;
  },
  choices: [
    for (final v in AHAH.values) ArgChoiceBuilder(v.toString(), v.toString()),
  ],
);

enum AHAH { create, delete }
