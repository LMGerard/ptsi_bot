import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class Test extends Command {
  Test() : super('test', 'A simple test function');

  @override
  Function get execute => (IChatContext context) async {
        respond(context, text: 'Hello world!');
      };
}
