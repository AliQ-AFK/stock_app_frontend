import 'package:flutter/material.dart';

/// A class holding all the color palettes for the application,
/// based on the design specifications.
///
/// This class contains color definitions for both light and dark themes
/// extracted from the Figma design system. All colors are organized
/// by their semantic meaning and usage context.
///
/// Usage:
/// ```dart
/// Container(
///   color: AppColors.lightBG,
///   child: Text(
///     'Hello World',
///     style: TextStyle(color: AppColors.lightText),
///   ),
/// )
/// ```
class AppColors {
  AppColors._(); // This class is not meant to be instantiated.

  // --- Light Theme Colors ---

  /// Primary red color for light theme - used for errors, alerts, and danger states
  static const Color lightRed = Color(0xFF8B4747);

  /// Primary text color for light theme - used for main content text
  static const Color lightText = Color(0xFF1C1C1C);

  /// Background color for light theme - used for main app background
  static const Color lightBG = Color(0xFFFFFDFD);

  /// Grey background color for light theme - used for secondary backgrounds
  static const Color lightGreyBG = Color(0xFFD9D9D9);

  /// Green color for light theme - used for success states and positive indicators
  static const Color lightGreen = Color(0xFF2A4E0A);

  /// Green background color for light theme - used for success backgrounds
  static const Color lightGreenBG = Color(0xFF88FE99);

  /// Stocks slider color for light theme - used for stock-related UI elements
  static const Color lightStocksSlider = Color(0xFF1C1C1C);

  /// Big elements color for light theme - used for prominent UI components
  static const Color lightBigElements = Color(0xFFD9D9D9);

  /// Dashboard and portfolio background color for light theme
  static const Color lightBGDashPort = Color(0xFFA4A4A4);

  // --- Dark Theme Colors ---

  /// Primary red color for dark theme - used for errors, alerts, and danger states
  static const Color darkRed = Color(0xFFFFA1A1);

  /// Primary text color for dark theme - used for main content text
  static const Color darkText = Color(0xFFF2F2F2);

  /// Background color for dark theme - used for main app background
  static const Color darkBG = Color(0xFF1C1C1C);

  /// Grey background color for dark theme - used for secondary backgrounds
  static const Color darkGreyBG = Color(0xFFD9D9D9);

  /// Green color for dark theme - used for success states and positive indicators
  static const Color darkGreen = Color(0xFF88FE99);

  /// Green background color for dark theme - used for success backgrounds
  static const Color darkGreenBG = Color(0xFFDAF5DE);

  /// Stocks slider color for dark theme - used for stock-related UI elements
  static const Color darkStocksSlider = Color(0xFF6B6969);

  /// Big elements color for dark theme - used for prominent UI components
  static const Color darkBigElements = Color(0xFF848484);

  /// Dashboard and portfolio background color for dark theme
  static const Color darkBGDashPort = Color(0xFF484545);

  // --- Helper Methods ---

  /// Returns the appropriate color based on the current theme brightness
  ///
  /// Usage:
  /// ```dart
  /// Color textColor = AppColors.getColor(
  ///   light: AppColors.lightText,
  ///   dark: AppColors.darkText,
  ///   brightness: Theme.of(context).brightness,
  /// );
  /// ```
  static Color getColor({
    required Color light,
    required Color dark,
    required Brightness brightness,
  }) {
    return brightness == Brightness.light ? light : dark;
  }

  /// Returns red color based on theme brightness
  static Color getRed(Brightness brightness) =>
      getColor(light: lightRed, dark: darkRed, brightness: brightness);

  /// Returns text color based on theme brightness
  static Color getText(Brightness brightness) =>
      getColor(light: lightText, dark: darkText, brightness: brightness);

  /// Returns background color based on theme brightness
  static Color getBG(Brightness brightness) =>
      getColor(light: lightBG, dark: darkBG, brightness: brightness);

  /// Returns grey background color based on theme brightness
  static Color getGreyBG(Brightness brightness) =>
      getColor(light: lightGreyBG, dark: darkGreyBG, brightness: brightness);

  /// Returns green color based on theme brightness
  static Color getGreen(Brightness brightness) =>
      getColor(light: lightGreen, dark: darkGreen, brightness: brightness);

  /// Returns green background color based on theme brightness
  static Color getGreenBG(Brightness brightness) =>
      getColor(light: lightGreenBG, dark: darkGreenBG, brightness: brightness);

  /// Returns stocks slider color based on theme brightness
  static Color getStocksSlider(Brightness brightness) => getColor(
    light: lightStocksSlider,
    dark: darkStocksSlider,
    brightness: brightness,
  );

  /// Returns big elements color based on theme brightness
  static Color getBigElements(Brightness brightness) => getColor(
    light: lightBigElements,
    dark: darkBigElements,
    brightness: brightness,
  );

  /// Returns dashboard/portfolio background color based on theme brightness
  static Color getBGDashPort(Brightness brightness) => getColor(
    light: lightBGDashPort,
    dark: darkBGDashPort,
    brightness: brightness,
  );
}
