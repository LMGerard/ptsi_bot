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
  final Map<String, List<_Question>> data = {};
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
      data[path.basenameWithoutExtension(e)] =
          csv.map((e) => _Question(e)).toList();
    }
  }

  @override
  FutureOr execute(event) async {
    final theme = event.args.isEmpty
        ? data.keys.elementAt(Random().nextInt(data.length))
        : event.getArg('theme').value as String;

    final question = data[theme]![Random().nextInt(data[theme]!.length)];

    final props = question.props..shuffle();
    String text = '\n**${question.question}** : \n```diff\n';

    final msg = ComponentRowBuilder();
    final emojis = {1: '1️⃣', 2: '2️⃣', 3: '3️⃣', 4: '4️⃣'};

    for (int i = 1; i <= 4; i++) {
      final prop = props.removeAt(0);
      text += '\n$i. $prop';

      msg.addComponent(ButtonBuilder(
        '',
        prop == question.prop1 ? 'quizz0' : 'quizz$i',
        ComponentStyle.secondary,
        emoji: UnicodeEmoji(emojis[i]!),
      ));
    }
    text += '```';

    sendEmbed<EMBED_RESPOND>(
      event,
      title: ' - $theme - ${question.index}',
      componentRowBuilders: [msg],
      text: text,
    );
  }

  @override
  Map<String, Function(IButtonInteractionEvent p1)> get buttons => {
        'quizz0': answerSelected,
        'quizz1': answerSelected,
        'quizz2': answerSelected,
        'quizz3': answerSelected,
        'quizz4': answerSelected,
      };

  answerSelected(IButtonInteractionEvent event) {
    final msg = event.interaction.message;

    if (msg == null) return event.acknowledge();

    final row = ComponentRowBuilder();
    if (event.interaction.customId == 'quizz0') {
      row.addComponent(ButtonBuilder('', 'quizz0', ComponentStyle.success,
          emoji: UnicodeEmoji('✅'), disabled: true));
    } else {
      row.addComponent(ButtonBuilder('', 'quizz0', ComponentStyle.danger,
          emoji: UnicodeEmoji('❌'), disabled: true));
    }

    final info = msg.embeds.first.title!.split('-');
    final question = data[info[1].trim()]?[int.parse(info[2].trim())];

    sendEmbed<EMBED_RESPOND>(
      event,
      componentRowBuilders: [row],
      text: '**${question?.question}**```diff\n+${question?.prop1}```',
    );
  }
}

class _Question {
  final int index;
  final String lang;
  final String question;
  final String prop1;
  final String prop2;
  final String prop3;
  final String prop4;

  _Question(List data)
      : index = data[0] - 1,
        lang = data[1].toString(),
        question = data[2].toString(),
        prop1 = data[3].toString(),
        prop2 = data[4].toString(),
        prop3 = data[5].toString(),
        prop4 = data[6].toString();

  List<String> get props => [prop1, prop2, prop3, prop4];
  String get answer => prop1;
}
