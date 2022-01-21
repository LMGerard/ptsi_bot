import 'dart:async';
import 'command.dart';

class Test extends Command {
  final url = Uri.parse(
    'http://ronan.lauvergnat.fr/Enseignements_actuels_RL.html',
  );

  Test() : super('test', 'A test command', []);

  @override
  FutureOr execute(event) async {
    event.acknowledge();
  }

  void test() async {}
}
