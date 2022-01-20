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
    final text = nouns.take(3).join(' ');
    final im = generateImage(text);

    final mem = MemoryFileSystem().file('temp.png')
      ..writeAsBytesSync(encodePng(im));

    event.respond(
      MessageBuilder.files([
        AttachmentBuilder.file(mem),
      ]),
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
          (v) => channel.sendMessage(
            MessageBuilder.content("${v.message.member?.mention} won !!"),
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
