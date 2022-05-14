import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx/nyxx.dart';
import 'package:english_words/english_words.dart';
import 'package:image/image.dart';
import 'dart:math';

import 'package:ptsi_bot_2/settings.dart';

class Precision extends Command {
  Precision() : super('precision', 'Write as fast as you can !');

  @override
  Function get execute => (IChatContext context) async {
        final r = Random();
        final text = Iterable.generate(
            3, (_) => nouns.elementAt(r.nextInt(nouns.length))).join(' ');
        final im = generateImage(text);

        final attach = AttachmentBuilder.bytes(encodePng(im), 'precision.png');

        await respond(context, attachment: attach);

        final channel = context.channel;
        (context.client as INyxxWebsocket)
            .eventsWs
            .onMessageReceived
            .firstWhere(
              (e) =>
                  e.message.channel.id == channel.id &&
                  e.message.content == text &&
                  e.message.author.bot == false,
            )
            .then(
          (v) {
            respond(
              context,
              text: "<@${v.message.author}> won !!",
            );
          },
        ).timeout(Duration(minutes: 1), onTimeout: () => null);
      };

  Image generateImage(String text) {
    var im = Image(400, 100)..fill(themeColor.abgr);

    fillRect(im, 20, 20, 380, 80, 0xFFFFFFFF);
    drawStringCentered(im, arial_24, text, color: 0xFF000000);
    return im;
  }
}
