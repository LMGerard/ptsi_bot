import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/utils/path.dart';
import 'command.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

final FILE_PATH = path.join(PATH, 'resources', 'liaisons.jpg');

class Liaisons extends Command {
  static final Map<String, List<Image>> links = {
    'Glissière': [],
    'Plan': [],
    'Pivot': [],
    'Hélicoïdale': [],
    'Pivot Glissant': [],
    'Linéaire rectiligne': [],
    'Rotule à doigts': [],
    'Rotule': [],
    'Linéaire Annulaire': [],
    'Ponctuelle': [],
  };
  final Map<String, String> games = {};
  final Image im = decodeImage(
    File(FILE_PATH).readAsBytesSync(),
  )!;

  Liaisons()
      : super("liaisons", "révise tes liaisons", [
          CommandOptionBuilder(
            CommandOptionType.string,
            'show',
            'Show info about liaisons.',
            choices: links.keys.map((e) => ArgChoiceBuilder(e, e)).toList(),
          ),
          CommandOptionBuilder(
            CommandOptionType.string,
            'answer',
            'Show info about liaisons.',
            choices: links.keys.map((e) => ArgChoiceBuilder(e, e)).toList(),
          ),
        ]) {
    final columns = [349, 1058, 1441];
    final rows = [172, 396, 638, 854, 1087, 1313, 1537, 1756, 1940, 2190, 2471];

    for (var i = 1; i < rows.length; i++) {
      final y = rows[i - 1];
      final height = rows[i] - y;

      final liaison = links.keys.elementAt(i - 1);

      for (var j = 1; j < columns.length; j++) {
        final x = columns[j - 1];
        final width = columns[j] - x;

        final imCrop = copyCrop(im, x, y, width, height);
        links[liaison]!.add(imCrop);
      }
    }
  }

  @override
  FutureOr execute(event) {
    if (event.args.isEmpty) return quizz(event);

    switch (event.args.first.name) {
      case 'show':
        return show(event);
      case 'answer':
        return answer(event);
    }
  }

  FutureOr show(ISlashCommandInteractionEvent event) {
    final linkName = event.getArg('show').value;

    final link = Liaisons.links[linkName]!;
    final bytes = AttachmentBuilder.bytes(
      encodePng(link[0]),
      'liaisons.png',
    );

    sendEmbed<EMBED_RESPOND>(
      event,
      text: 'Voici la liaison $linkName',
      attachment: bytes,
    );
  }

  FutureOr answer(ISlashCommandInteractionEvent event) {
    final user = event.interaction.userAuthor;

    if (user == null) return event.acknowledge();

    final linkName = games['$user'];

    if (linkName == null) {
      return sendEmbed<EMBED_RESPOND>(
        event,
        text: "Tu dois participer à un quizz pour utiliser cette commande !",
      );
    }

    if (linkName != event.getArg('answer').value) {
      return sendEmbed<EMBED_RESPOND>(
        event,
        text: "Mauvaise réponse ! C'est une liaison $linkName !",
      );
    } else {
      sendEmbed<EMBED_RESPOND>(
        event,
        text: "Bravo ! C'est bien une liaison $linkName !",
      );
    }
  }

  FutureOr quizz(ISlashCommandInteractionEvent event) {
    final user = event.interaction.userAuthor;
    if (user == null) return event.acknowledge();

    final lEntry = links.entries.elementAt(Random().nextInt(links.length));

    final im = links[lEntry.key]![Random().nextInt(lEntry.value.length)];

    final bytes = AttachmentBuilder.bytes(
      encodePng(im),
      'liaisons.png',
    );

    games['$user'] = lEntry.key;

    sendEmbed<EMBED_RESPOND>(
      event,
      text: 'Quelle est cette liaison ? Réponds avec une commande !',
      attachment: bytes,
    );
  }
}
