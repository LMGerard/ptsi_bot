import 'dart:async';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot/utils/path.dart';
import 'command.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

final FILE_PATH = path.join(
  PATH,
  'resources',
  'quizz',
  'openquizzdb_26.csv',
);

class Quizz extends Command with HasButton {
  final List<List<dynamic>> data = [];
  Quizz() : super('quizz', 'Quizz it up !', []) {
    final fC = File(FILE_PATH).readAsStringSync();
    data.addAll(
        CsvToListConverter().convert(fC, fieldDelimiter: ';', eol: '\n'));
  }

  @override
  FutureOr execute(event) async {
    final row = data[Random().nextInt(data.length)];
    final props = row.sublist(3, 7)..shuffle();
    String text = '**${row[2]}** : \n';

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

    final cmb = ComponentMessageBuilder()
      ..addComponentRow(msg)
      ..content = text;
    event.respond(cmb);
  }

  void test() async {}

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
    event.respond(ComponentMessageBuilder()
      ..addComponentRow(row)
      ..content = msg.content);
  }
}
