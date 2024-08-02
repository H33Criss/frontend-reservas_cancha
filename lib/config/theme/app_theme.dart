// lib/config/theme.dart

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  static ShadThemeData getShadTheme(Size size) {
    return ShadThemeData(
      brightness: Brightness.dark,
      textTheme: ShadTextTheme(
        family: 'Kanit',
      ),
      // colorScheme: const ShadSlateColorScheme.dark(),
      colorScheme: const ShadSlateColorScheme.dark(muted: Colors.blue),
      buttonSizesTheme: ShadButtonSizesTheme(
        lg: ShadButtonSizeTheme(
          height: size.height * 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }

  static ThemeData getMaterialTheme() {
    return ThemeData(
      fontFamily: 'Kanit',
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blue[600],
    );
  }

  static ShadThemeData getDarkShadTheme(Size size) {
    return ShadThemeData(
      buttonSizesTheme: ShadButtonSizesTheme(
        lg: ShadButtonSizeTheme(
          height: size.height * 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
      textTheme: ShadTextTheme(
        family: 'Kanit',
      ),
      brightness: Brightness.dark,
      // colorScheme: const ShadSlateColorScheme.dark(),
      colorScheme: const ShadSlateColorScheme.dark(muted: Colors.blue),
    );
  }
}
