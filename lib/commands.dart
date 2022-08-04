import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:ptsi_bot_2/cli/cli.dart';
import 'package:ptsi_bot_2/commands/avatar.dart';
import 'package:ptsi_bot_2/commands/emoji_text.dart';
import 'package:ptsi_bot_2/commands/int_to_bin.dart';
import 'package:ptsi_bot_2/commands/liaisons.dart';
import 'package:ptsi_bot_2/commands/music.dart';
import 'package:ptsi_bot_2/commands/pgcd.dart';
import 'package:ptsi_bot_2/commands/precision.dart';
import 'package:ptsi_bot_2/commands/quizz.dart';
import 'package:ptsi_bot_2/commands/ronan.dart';
import 'package:ptsi_bot_2/commands/test.dart';
import 'package:ptsi_bot_2/commands/wc.dart';
import 'package:ptsi_bot_2/settings.dart';

final commands = [
  Test(),
  Avatar(),
  Precision(),
  Liaisons(),
  Ronan(),
  Music(),
  PGCD(),
  WC(),
  Quizz(),
  Text2emojis(),
  IntToBin(),
];

abstract class SupCommand {
  void register(CommandsPlugin plugin);

  Future<IMessage> respond(
    event, {
    String? title,
    String? text,
    AttachmentBuilder? attachment,
    MultiselectBuilder? multiselect,
    List<ComponentRowBuilder>? rows,
    String? imageUrl,
    bool private = false,
  }) async {
    final msg = createMessage(
      title: title,
      text: text,
      attachment: attachment,
      multiselect: multiselect,
      rows: rows,
      imageUrl: imageUrl,
    );
    if (event is IInteractionEventWithAcknowledge) {
      if (Cli.hiddens.contains(event.interaction.userAuthor?.id.id)) {
        private = true;
      }
      await event.respond(msg, hidden: private);
      return event.getOriginalResponse();
    } else if (event is IChatContext) {
      if (Cli.hiddens.contains(event.user.id.id)) {
        private = true;
      }
      return event.respond(msg, private: private);
    } else {
      throw ArgumentError(
        'event must be an IInteractionEventWithAcknowledge or IChatContext',
      );
    }
  }

  MessageBuilder createMessage({
    String? title,
    String? text,
    AttachmentBuilder? attachment,
    MultiselectBuilder? multiselect,
    List<ComponentRowBuilder>? rows,
    String? imageUrl,
  }) {
    final embed = createEmbed(
      title: '$runtimeType${title ?? ''}',
      text: text,
      imageUrl: imageUrl,
    );
    final msg = ComponentMessageBuilder()..embeds = [embed];

    if (multiselect != null) {
      msg.addComponentRow(ComponentRowBuilder()..addComponent(multiselect));
    }
    if (rows != null && rows.isNotEmpty) {
      for (final row in rows) {
        msg.addComponentRow(row);
      }
    }

    if (attachment != null) msg.addAttachment(attachment);

    return msg;
  }

  EmbedBuilder createEmbed({String? title, String? text, String? imageUrl}) {
    return EmbedBuilder()
      ..color = themeColor.color
      ..title = title
      ..imageUrl = imageUrl
      ..description = text;
  }
}

abstract class Command extends SupCommand {
  late final ChatCommand _command;
  final List<Converter> converters;
  Function get execute;

  Iterable<String> get args => _command.argumentTypes.map((t) => "$t");
  String get name => _command.name;
  Command(
    String name,
    String description, {
    List<Converter>? converters,
  }) : converters = converters ?? [] {
    _command = ChatCommand(name, description, execute,
        singleChecks: [GuildCheck.all()]);
  }

  @override
  void register(plugin) {
    for (final conv in converters) {
      plugin.addConverter(conv);
    }
    plugin.addCommand(_command);
  }
}

abstract class CommandGroup extends SupCommand {
  late final ChatGroup _group;
  final List<Converter> converters;
  CommandGroup(String name, String description, Iterable<SubCommand>? children,
      {this.converters = const []}) {
    _group = ChatGroup(
      name,
      description,
      children: children!.map((e) => e._command),
    );
  }

  @override
  void register(plugin) {
    for (final conv in converters) {
      plugin.addConverter(conv);
    }
    plugin.addCommand(_group);
  }
}

abstract class SubCommand extends Command {
  SubCommand(String name, String description) : super(name, description) {
    assert(!(SubCommand is hasButton || SubCommand is hasMultiSelect),
        'Please refer to your buttons and multiselect into the CommandGroup');
  }
}

mixin hasButton on SupCommand {
  Map<String, Function(IButtonInteractionEvent p1)> get buttons;

  @override
  void register(plugin) {
    for (final b in buttons.entries) {
      plugin.interactions.registerButtonHandler(b.key, b.value);
    }
    super.register(plugin);
  }
}

mixin hasMultiSelect on SupCommand {
  Map<String, Function(IMultiselectInteractionEvent p1)> get multiSelects;

  @override
  void register(plugin) {
    for (final b in multiSelects.entries) {
      plugin.interactions.registerMultiselectHandler(b.key, b.value);
    }
    super.register(plugin);
  }
}
