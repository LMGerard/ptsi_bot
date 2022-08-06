import 'package:nyxx/nyxx.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

class Music extends CommandGroup {
  static late final ICluster cluster;

  Music()
      : super('music', 'A music player. Obviously...', [
          _Play(),
          _Pause(),
          _Resume(),
          _Stop(),
          _Clear(),
        ]);

  static init(INyxxWebsocket bot) {
    Music.cluster = ICluster.createCluster(bot, bot.appId);
    Music.cluster.addNode(
      NodeOptions(
        host: 'lava.link',
        port: 80,
        password: "password",
        ssl: false,
      ),
    );
  }

  static INode node(Snowflake guildId) =>
      Music.cluster.getOrCreatePlayerNode(guildId);
}

class _Play extends SubCommand {
  _Play() : super('play', 'Play a song.');
  @override
  Function get execute => (IChatContext context, String url) async {
        final channel = await context.member?.voiceState?.channel
            ?.getOrDownload() as IVoiceGuildChannel?;

        if (channel == null) {
          return respond(context, text: 'You have to be in a voice channel.');
        }

        final node = Music.node(context.guild!.id);

        final searchResults = await node.autoSearch(url);
        if (searchResults.tracks.isEmpty) {
          return respond(context, text: 'No result found.');
        }

        channel.connect();
        // add found song to queue and play
        node.play(context.guild!.id, searchResults.tracks[0]).queue();

        respond(
          context,
          text: 'Added ${searchResults.tracks[0].info?.title} to queue',
        );
      };
}

class _Pause extends SubCommand {
  _Pause() : super('pause', 'Pause the music.');
  @override
  Function get execute => (IChatContext context) async {
        Music.node(context.guild!.id).pause(context.guild!.id);

        respond(context, text: "Music paused");
      };
}

class _Resume extends SubCommand {
  _Resume() : super('resume', 'Resume the music.');
  @override
  Function get execute => (IChatContext context) async {
        Music.node(context.guild!.id).resume(context.guild!.id);

        respond(context, text: "Music resumed");
      };
}

class _Stop extends SubCommand {
  _Stop() : super('stop', 'Stop the music.');
  @override
  Function get execute => (IChatContext context) async {
        Music.node(context.guild!.id).stop(context.guild!.id);

        respond(context, text: "Music stopped");
      };
}

class _Clear extends SubCommand {
  _Clear() : super('skip', 'Skip the music.');
  @override
  Function get execute => (IChatContext context) async {
        Music.node(context.guild!.id).clearPlayers();
        respond(context, text: "Music queue cleared");
      };
}
