import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

import 'command.dart';

class Test extends Command with HasButton {
  Test() : super('test', 'A test command', []);

  @override
  FutureOr execute(event) async {
    final msg = ComponentRowBuilder();
    msg.addComponent(ButtonBuilder('label', 'test0', ComponentStyle.success));

    final cmb = ComponentMessageBuilder()
      ..addComponentRow(msg)
      ..content = 'test';
    event.respond(cmb);
  }

  void test() async {
    final a = '|21| En quelle an';
    final qIndex = RegExp(r"\|[\d]*\|").firstMatch(a)?.group(0);
    print(qIndex);
  }

  @override
  Map<String, Function(IButtonInteractionEvent p1)> get buttons => {
        'test0': (event) {
          sendEmbed<EMBED_RESPOND>(event, text: 'dqzdzqd');
        },
      };
}
