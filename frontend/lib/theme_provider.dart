import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void toggleTheme() {
  themeNotifier.value = themeNotifier.value == ThemeMode.light
      ? ThemeMode.dark
      : ThemeMode.light;
}
