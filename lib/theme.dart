import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

// https://rydmike.com/flexcolorscheme/themesplayground-latest/?config=H4sIAHiALWgA_61UTY-bMBC9769AnFdRlijqNrd8rRRVkaqSntGsGRKrxkb2OBu02v_ewcC2gai9hAvI78288fMz7w8RP3GloD5a43We5UAQL6L4cMISXfT9E4kaJMJLZSxhHiVPk-l8kkyTeTT9uki-LOZJ_DjqdkbrpNFNw-dJMpn2FGHKCgTtTY6MFaAcdkiOBXhFPyCX3jH23K0XygBJfVwK4oYrT2T0Ur1B7dbSCq_ADhrdKvjpMD1BNdSUuvK0QWEskLErY3O0hzrQ3gOjnQwsZdQux6h9mRUKL1kozl5DUQs__qk5g_KBz2agVVJjHMCPm8o79yKVwnw0HqGFsI1tUaCgxheyvseVdHSQClNUDGKeiubs1kYZ-78duEDNRODemruysgRbX089FAzfdxQ1OmVLdD4Sbit37OWFecmsXz6Zt7SD2M8wxMAjJ0vOCHu8rKq-fjrE1pxKo1GTG1E0iF8rsCt-tdG-8369LUAMwtGL3lPK9caujSbgPNprTWrqu2v5T6VAzMqGeUtHyeOJBq2bHOcb6eCVM97oW6MGx0SmkiKYv2WLZRgjGWEp8Tgd-tQfkXf4wvcx2NQ6dt2a8d3VbTu0gdlIUOboRuRvWH8G6e_byNA-SalWuJFnnsHu9H42qt7PttY2iRpHsUGBbzTrjutS_9r-ea8R_o-SFKC6k2mQh4_fXD9cIL0FAAA=

abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.amber,
    // Input color modifiers.
    useMaterial3ErrorColors: true,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
      listTileSelectedSchemeColor: SchemeColor.primary,
      listTileSelectedTileSchemeColor: SchemeColor.onSecondary,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      snackBarBackgroundSchemeColor: SchemeColor.secondaryContainer,
      snackBarActionSchemeColor: SchemeColor.onSurface,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.amber,
    // Input color modifiers.
    useMaterial3ErrorColors: true,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 8.0,
      listTileSelectedSchemeColor: SchemeColor.primary,
      listTileSelectedTileSchemeColor: SchemeColor.onSecondary,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      snackBarBackgroundSchemeColor: SchemeColor.secondaryContainer,
      snackBarActionSchemeColor: SchemeColor.onSurface,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}

/// Light [ColorScheme] made with FlexColorScheme v8.2.0.
/// Requires Flutter 3.22.0 or later.
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFE65100),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFCC80),
  onPrimaryContainer: Color(0xFF000000),
  primaryFixed: Color(0xFFFFD7C2),
  primaryFixedDim: Color(0xFFFAB38C),
  onPrimaryFixed: Color(0xFF5D2100),
  onPrimaryFixedVariant: Color(0xFF6F2700),
  secondary: Color(0xFF2979FF),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE4EAFF),
  onSecondaryContainer: Color(0xFF000000),
  secondaryFixed: Color(0xFFD6E3F8),
  secondaryFixedDim: Color(0xFFAAC5F1),
  onSecondaryFixed: Color(0xFF00348B),
  onSecondaryFixedVariant: Color(0xFF003B9D),
  tertiary: Color(0xFF2962FF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFCBD6FF),
  onTertiaryContainer: Color(0xFF000000),
  tertiaryFixed: Color(0xFFD6DFF8),
  tertiaryFixedDim: Color(0xFFAABDF1),
  onTertiaryFixed: Color(0xFF00258B),
  onTertiaryFixedVariant: Color(0xFF002A9D),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFCFCFC),
  onSurface: Color(0xFF111111),
  surfaceDim: Color(0xFFE0E0E0),
  surfaceBright: Color(0xFFFDFDFD),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF8F8F8),
  surfaceContainer: Color(0xFFF3F3F3),
  surfaceContainerHigh: Color(0xFFEDEDED),
  surfaceContainerHighest: Color(0xFFE7E7E7),
  onSurfaceVariant: Color(0xFF393939),
  outline: Color(0xFF919191),
  outlineVariant: Color(0xFFD1D1D1),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2A2A2A),
  onInverseSurface: Color(0xFFF1F1F1),
  inversePrimary: Color(0xFFFFCF99),
  surfaceTint: Color(0xFFE65100),
);

/// Dark [ColorScheme] made with FlexColorScheme v8.2.0.
/// Requires Flutter 3.22.0 or later.
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB300),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFFC87200),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFFFFD7C2),
  primaryFixedDim: Color(0xFFFAB38C),
  onPrimaryFixed: Color(0xFF5D2100),
  onPrimaryFixedVariant: Color(0xFF6F2700),
  secondary: Color(0xFF82B1FF),
  onSecondary: Color(0xFF000000),
  secondaryContainer: Color(0xFF3770CF),
  onSecondaryContainer: Color(0xFFFFFFFF),
  secondaryFixed: Color(0xFFD6E3F8),
  secondaryFixedDim: Color(0xFFAAC5F1),
  onSecondaryFixed: Color(0xFF00348B),
  onSecondaryFixedVariant: Color(0xFF003B9D),
  tertiary: Color(0xFF448AFF),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF0B429C),
  onTertiaryContainer: Color(0xFFFFFFFF),
  tertiaryFixed: Color(0xFFD6DFF8),
  tertiaryFixedDim: Color(0xFFAABDF1),
  onTertiaryFixed: Color(0xFF00258B),
  onTertiaryFixedVariant: Color(0xFF002A9D),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF080808),
  onSurface: Color(0xFFF1F1F1),
  surfaceDim: Color(0xFF060606),
  surfaceBright: Color(0xFF2C2C2C),
  surfaceContainerLowest: Color(0xFF010101),
  surfaceContainerLow: Color(0xFF0E0E0E),
  surfaceContainer: Color(0xFF151515),
  surfaceContainerHigh: Color(0xFF1D1D1D),
  surfaceContainerHighest: Color(0xFF282828),
  onSurfaceVariant: Color(0xFFCACACA),
  outline: Color(0xFF777777),
  outlineVariant: Color(0xFF414141),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE8E8E8),
  onInverseSurface: Color(0xFF2A2A2A),
  inversePrimary: Color(0xFF6B520A),
  surfaceTint: Color(0xFFFFB300),
);
