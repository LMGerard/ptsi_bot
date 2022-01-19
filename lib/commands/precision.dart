import 'package:file/memory.dart';

import 'command.dart';
import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:image/image.dart';
import 'package:english_words/english_words.dart';

class Precision extends SingleCommand {
  @override
  String get name => 'precision';
  @override
  String get description => 'Write the sentence as fast as you can.';

  @override
  FutureOr execute(event) {
    final im = generateImage();

    final mem = MemoryFileSystem().file('temp.png')
      ..writeAsBytesSync(encodePng(im));

    event.respond(
      MessageBuilder.files([
        AttachmentBuilder.file(mem),
      ]),
    );
  }

  Image generateImage() {
    var im = Image(400, 100)..fill(0x4a9476);

    im = drawString(im, arial_24, 20, 40, nouns.take(3).join(' '));

    return im;
  }
}
