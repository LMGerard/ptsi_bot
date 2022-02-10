import 'dart:async';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/utils/path.dart';
import 'command.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

final basePath = path.join(PATH, 'resources', 'quizz');
final quizzesPaths = Directory(basePath).listSync().map((e) => e.path);

class Quizz extends Command with HasButton {
  final Map<String, List<List<dynamic>>> data = {};
  Quizz()
      : super('quizz', 'Quizz it up !', [
          CommandOptionBuilder(
            CommandOptionType.string,
            'theme',
            'theme',
            choices: quizzesPaths
                .map((e) => ArgChoiceBuilder(
                      path.basenameWithoutExtension(e),
                      path.basenameWithoutExtension(e),
                    ))
                .toList(),
          )
        ]) {
    for (final e in quizzesPaths) {
      final file = File(e);
      final csv = CsvToListConverter()
          .convert(file.readAsStringSync(), fieldDelimiter: ';', eol: '\n');
      data[path.basenameWithoutExtension(e)] = csv;
    }
  }

  @override
  FutureOr execute(event) async {
    final theme = event.args.isEmpty
        ? data.keys.elementAt(Random().nextInt(data.length))
        : event.getArg('theme').value as String;

    final row = data[theme]![Random().nextInt(data[theme]!.length)];

    final props = row.sublist(3, 7)..shuffle();
    String text = '**Quizz  -  $theme\n****${row[2]}** : \n';

    final msg = ComponentRowBuilder();
    final emojis = {1: '1️⃣', 2: '2️⃣', 3: '3️⃣', 4: '4️⃣'};

    for (int i = 1; i <= 4; i++) {
      final prop = props.removeAt(0);
      text += '\n$i. $prop';

      msg.addComponent(ButtonBuilder(
        '',
        prop == row[3] ? 'quizz0' : 'quizz$i',
        ComponentStyle.secondary,
        emoji: UnicodeEmoji(emojis[i]!),
      ));
    }

    sendEmbed<EMBED_RESPOND>(event, componentRowBuilders: [msg], text: text);
  }

  @override
  Map<String, Function(IButtonInteractionEvent p1)> get buttons => {
        'quizz0': answerSelected,
        'quizz1': answerSelected,
        'quizz2': answerSelected,
        'quizz3': answerSelected,
        'quizz4': answerSelected,
      };

  void answerSelected(IButtonInteractionEvent event) {
    final msg = event.interaction.message;

    if (msg == null) return;

    final row = ComponentRowBuilder();
    if (event.interaction.customId == 'quizz0') {
      row.addComponent(ButtonBuilder('', 'quizz0', ComponentStyle.success,
          emoji: UnicodeEmoji('✅'), disabled: true));
    } else {
      row.addComponent(ButtonBuilder('', 'quizz0', ComponentStyle.danger,
          emoji: UnicodeEmoji('❌'), disabled: true));
    }

    sendEmbed<EMBED_RESPOND>(
      event,
      componentRowBuilders: [row],
      text: msg.content,
    );
  }
}
