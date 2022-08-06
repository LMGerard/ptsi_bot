FROM dart:stable


WORKDIR /code

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
CMD dart run ./bin/ptsi_bot.dart