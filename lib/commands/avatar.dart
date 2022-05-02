import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';

class Avatar extends Command {
  Avatar()
      : super('avatar', 'Display user avatar', [
          CommandOptionBuilder(
            CommandOptionType.mentionable,
            'user',
            'user to display avatar of',
            required: true,
          ),
        ]);

  @override
  Future execute(ISlashCommandInteractionEvent event) async {
    final userId = event.interaction.getArg('user');

    final user =
        await (event.client as INyxxWebsocket).fetchUser(Snowflake(userId));

    final embed = createEmbed()..imageUrl = user.avatarURL();
    event.respond(MessageBuilder.embed(embed));
  }
}
