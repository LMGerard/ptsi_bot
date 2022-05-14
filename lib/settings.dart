import 'package:nyxx/nyxx.dart';
import 'dart:io';

const ptsiToken = "OTAxNzgzNzIzMTEwOTY1MzE4.YXU5iQ.JUiGtUC5YuEbIZPRa0uN9BqLg5c";
const uselessToken =
    "ODAyNjk0MTk3NDYyODI3MDE5.YAy9Og.5UlqjgRPlBSg7tNXD8oTy_AeJLI";
const prefix = '*';
const themeColor = _Color(52, 152, 219, 255);

// ignore: non_constant_identifier_names
String get PATH => Platform.isLinux
    ? '/home/pi/Downloads/BOT/ptsi_bot/'
    : Directory.current.path;

class _Color {
  final int r, g, b, a;
  const _Color(this.r, this.g, this.b, this.a);

  int get rgb => (r << 16) | (g << 8) | b;
  int get rgba => (r << 24) | (g << 16) | (b << 8) | a;
  int get bgr => (b << 16) | (g << 8) | r;
  int get bgra => (b << 24) | (g << 16) | (r << 8) | a;
  int get abgr => (a << 24) | (b << 16) | (g << 8) | r;

  DiscordColor get color => DiscordColor.fromRgb(r, g, b);
}
