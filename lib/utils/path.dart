import 'dart:io';

String get PATH => Platform.isLinux
    ? '/home/pi/Downloads/BOT/ptsi_bot/'
    : Directory.current.path;
