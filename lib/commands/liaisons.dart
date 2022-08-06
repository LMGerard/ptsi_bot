import 'dart:io';
import 'package:image/image.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:path/path.dart' as path;
import 'package:ptsi_bot_2/settings.dart';

final filePath = 'resources/liaisons.jpg';

class Liaisons extends Command {
  final im = decodeImage(File(filePath).readAsBytesSync())!;
  static final links = [
    Link('all', 0),
    Link('Glissière', 1),
    Link('Plan', 2),
    Link('Pivot', 3),
    Link('Hélicoïdale', 4),
    Link('Pivot Glissant', 5),
    Link('Linéaire rectiligne', 6),
    Link('Rotule à doigts', 7),
    Link('Rotule', 8),
    Link('Linéaire Annulaire', 9),
    Link('Ponctuelle', 10),
  ];

  Liaisons()
      : super(
          'liaisons',
          'Affiche les liaisons',
          converters: [linkConverter, linkCaracConverter],
        );

  @override
  Function get execute => (IChatContext context, Link? link) {
        if (link == null) {
          respond(context, text: "Aucune liaison n'est spécifiée");
        } else {
          show(context, link, LinkCarac.cinematicTorsor);
        }
      };

  Future show(IChatContext context, Link link, LinkCarac? carac) {
    late Image im;
    switch (carac) {
      case LinkCarac.name:
        im = link.name;
        break;
      case LinkCarac.scheme:
        im = link.scheme;
        break;
      case LinkCarac.cinematicTorsor:
        im = link.cinematicTorsor;
        break;
      case LinkCarac.mecanicTorsor:
        im = link.mecanicTorsor;
        break;
      default:
        im = link.row;
        break;
    }

    final bytes = AttachmentBuilder.bytes(encodePng(im), 'liaisons.png');

    return respond(
      context,
      text: 'Voici la liaison ${link.type}',
      attachment: bytes,
    );
  }
}

final linkConverter = Converter<Link>(
  (view, context) {
    final arg = view.getQuotedWord().toLowerCase();
    final t = Liaisons.links.where((e) => e.type.toLowerCase() == arg);
    return t.isEmpty ? null : t.first;
  },
  choices: [
    for (final link in Liaisons.links) ArgChoiceBuilder(link.type, link.type),
  ],
);

final linkCaracConverter = Converter<LinkCarac>(
  (view, context) {
    final arg = view.getQuotedWord().toLowerCase();
    final t = LinkCarac.values.where((e) => e.toString().toLowerCase() == arg);
    return t.isEmpty ? null : t.first;
  },
  choices: [
    for (final act in LinkCarac.values)
      ArgChoiceBuilder(act.toString(), act.toString()),
  ],
);

enum LinkCarac { name, scheme, cinematicTorsor, mecanicTorsor }

class Link {
  final im = decodeImage(File(filePath).readAsBytesSync())!;

  static const columns = [349, 1058, 1441, 1855];
  static const rows = [
    172,
    396,
    638,
    854,
    1087,
    1313,
    1537,
    1756,
    1940,
    2190,
    2471,
  ];

  final String type;
  final List<Image> images = [];
  final int _row;
  Link(this.type, int row) : _row = row;

  void addImage(Image image) => images.add(image);

  Image get row {
    if (_row == 0) return im;
    final y = rows[_row - 1];

    return copyCrop(im, 0, y, im.width, rows[_row] - y);
  }

  Image get name {
    if (_row == 0) return copyCrop(im, 96, 0, 349 - 96, im.height);
    final y = rows[_row - 1];

    return copyCrop(im, 96, y, 349 - 96, rows[_row] - y);
  }

  Image get scheme {
    if (_row == 0) return copyCrop(im, 349, 0, 1058 - 349, im.height);
    final y = rows[_row - 1];

    return copyCrop(im, 349, y, 1058 - 349, rows[_row] - y);
  }

  Image get cinematicTorsor {
    if (_row == 0) return copyCrop(im, 1058, 0, 1441 - 1058, im.height);
    final y = rows[_row - 1];

    return copyCrop(im, 1058, y, 1441 - 1058, rows[_row] - y);
  }

  Image get mecanicTorsor {
    if (_row == 0) return copyCrop(im, 1441, 0, 1855 - 1441, im.height);
    final y = rows[_row - 1];

    return copyCrop(im, 1441, y, 1855 - 1441, rows[_row] - y);
  }
}
