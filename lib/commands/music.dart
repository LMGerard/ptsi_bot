import 'dart:async';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';

class Music extends Command {
  static late final ICluster cluster;

  Music()
      : super('music', 'Obviously a music player...', [
          _MusicJoin(),
          _MusicPlay(),
          _MusicPause(),
          _MusicResume(),
          _MusicSkip(),
          _MusicStop(),
        ]);

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) {}
}

class _MusicJoin extends SubCommand {
  _MusicJoin() : super('join', 'Join a voice channel');

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) async {
    final channel = await event.interaction.memberAuthor?.voiceState?.channel
        ?.getOrDownload() as IVoiceGuildChannel?;

    if (channel == null) {
      event.respond(MessageBuilder.content('You are not in a voice channel'));
      return;
    }

    Music.cluster.getOrCreatePlayerNode(event.interaction.guild!.id);
    channel.connect();

    event.respond(MessageBuilder.content('Connected to #${channel.name}'));
  }
}

class _MusicPlay extends SubCommand {
  _MusicPlay()
      : super('play', 'Play a song', options: [
          CommandOptionBuilder(
            CommandOptionType.string,
            'keywords',
            'keywords to find your music',
            required: true,
          )
        ]);

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) async {
    final id = event.interaction.guild?.id;
    if (id == null) {
      return event.respond(MessageBuilder.content('An error occured.'));
    }

    final node = Music.cluster.getOrCreatePlayerNode(id);
    print(
      event.getArg('keywords').value,
    );

    // search for given query using lava link
    final searchResults = await node.autoSearch(
      event.getArg('keywords').value.toString(),
    );
    if (searchResults.tracks.isEmpty) {
      return event.respond(MessageBuilder.content('No results found'));
    }
    // add found song to queue and play
    node.play(id, searchResults.tracks[0]).queue();
    event.respond(
      MessageBuilder.content(
        'Added ${searchResults.tracks[0].info?.title} to queue',
      ),
    );
  }
}

class _MusicPause extends SubCommand {
  _MusicPause() : super('pause', 'Pause the current song');

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) async {
    final id = event.interaction.guild?.id;
    if (id == null) {
      return event.respond(MessageBuilder.content('An error occured.'));
    }
    final node = Music.cluster.getOrCreatePlayerNode(id);

    node.pause(id);
    event.respond(MessageBuilder.content('Music Paused'));
  }
}

class _MusicResume extends SubCommand {
  _MusicResume() : super('resume', 'Resume the current song');
  @override
  FutureOr execute(ISlashCommandInteractionEvent event) async {
    final id = event.interaction.guild?.id;
    if (id == null) {
      return event.respond(MessageBuilder.content('An error occured.'));
    }
    final node = Music.cluster.getOrCreatePlayerNode(id);

    node.resume(id);
    event.respond(MessageBuilder.content('Music Paused'));
  }
}

class _MusicSkip extends SubCommand {
  _MusicSkip() : super('skip', 'Skip the current song');

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) async {
    final id = event.interaction.guild?.id;
    if (id == null) {
      return event.respond(MessageBuilder.content('An error occured.'));
    }
    final node = Music.cluster.getOrCreatePlayerNode(id);

    node.skip(id);
    event.respond(MessageBuilder.content('Music Skipped'));
  }
}

class _MusicStop extends SubCommand {
  _MusicStop() : super('stop', 'Stop the current song');

  @override
  FutureOr execute(ISlashCommandInteractionEvent event) async {
    final id = event.interaction.guild?.id;
    if (id == null) {
      return event.respond(MessageBuilder.content('An error occured.'));
    }
    final node = Music.cluster.getOrCreatePlayerNode(id);

    node.stop(id);
    event.respond(MessageBuilder.content('Music Stopped'));
  }
}
