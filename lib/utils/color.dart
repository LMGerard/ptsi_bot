import 'package:nyxx/nyxx.dart';

const themeColor = Color(52, 152, 219, 255);

class Color {
  final int r, g, b, a;
  const Color(this.r, this.g, this.b, this.a);

  int get rgb => (r << 16) | (g << 8) | b;
  int get rgba => (r << 24) | (g << 16) | (b << 8) | a;
  int get bgr => (b << 16) | (g << 8) | r;
  int get bgra => (b << 24) | (g << 16) | (r << 8) | a;
  int get abgr => (a << 24) | (b << 16) | (g << 8) | r;

  DiscordColor get color => DiscordColor.fromRgb(r, g, b);
}
