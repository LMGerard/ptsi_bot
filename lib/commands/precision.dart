import 'dart:math';

import 'package:file/memory.dart';
import 'command.dart';
import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:image/image.dart';
import 'package:english_words/english_words.dart';

class Precision extends Command {
  Precision()
      : super('precision', 'Write the sentence as fast as you can.', []);

  @override
  FutureOr execute(event) async {
    final r = Random();
    final text =
        Iterable.generate(3, (_) => nouns.elementAt(r.nextInt(nouns.length)))
            .join(' ');
    final im = generateImage(text);

    final mem = MemoryFileSystem().file('temp.png')
      ..writeAsBytesSync(encodePng(im));

    final attach = AttachmentBuilder.file(mem);
    event.respond(
      MessageBuilder.files([attach]),
    );
    final channel = await event.interaction.channel.getOrDownload();

    (event.interaction.client as INyxxWebsocket)
        .eventsWs
        .onMessageReceived
        .firstWhere(
          (e) =>
              e.message.channel.id == channel.id &&
              e.message.content == text &&
              e.message.author.bot == false,
        )
        .then(
          (v) => sendEmbed<EMBED_SEND>(
            event,
            text: "<@${v.message.author}> won !!",
          ),
        )
        .timeout(Duration(minutes: 1));
  }

  Image generateImage(String text) {
    var im = Image(400, 100)..fill(0x4a9476);

    im = drawString(im, arial_24, 20, 40, text);

    return im;
  }
}
