import 'dart:async';

import 'command.dart';

class Test extends Command {
  Test() : super('test', 'A test command', []);

  @override
  FutureOr execute(event) async {}
}
