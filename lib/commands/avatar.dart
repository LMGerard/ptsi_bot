import 'package:nyxx/nyxx.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class Avatar extends Command {
  Avatar() : super('avatar', 'Get the avatar of a user or flex about yours.');

  @override
  Function get execute => (IChatContext context, IUser target) async {
        respond(context, imageUrl: target.avatarURL());
      };
}
