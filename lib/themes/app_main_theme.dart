import 'package:elephant/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static const int _defaultColor = 0xcafefeed;

  static ThemeData lightThemeData =
      themeData(lightColorSchemeGudGreen, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme,
      // Matches manifest.json colors and background color.
      primaryColor: const Color(0xFF030303),
      appBarTheme: const AppBarTheme(
        elevation: 1,
        // iconTheme: IconThemeData(color: colorScheme.primary),
      ),

      radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all<Color>(secondaryColor)),
      checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all<Color>(
              colorScheme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          fillColor: MaterialStateProperty.all<Color>(secondaryColor)),

      textSelectionTheme:
          const TextSelectionThemeData(selectionColor: secondaryColor),
      buttonBarTheme: const ButtonBarThemeData(
        buttonHeight: 15,
      ),
      // buttonTheme: const ButtonThemeData(colorScheme: ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,

      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
              color: colorScheme.brightness == Brightness.dark
                  ? _darkFillColor
                  : _lightFillColor),
          focusColor: colorScheme.primaryVariant,
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: secondaryColor)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          hintStyle: const TextStyle(color: sDark)),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: _textTheme.subtitle1?.apply(color: _darkFillColor),
      ),
    );
  }

  // static const ColorScheme lightColorScheme = ColorScheme(
  //   // primary: Color(0xFFaebfbe),
  //   primary: Color(0xFFe0f2f1),
  //   primaryVariant: Color(0xFFaebfbe),
  //   secondary: Color(0xFF757575),
  //   secondaryVariant: Color(0xFF494949),
  //   // background: Color(0xFFE6EBEB),
  //   background: Colors.white,
  //   surface: Color(0xFFFAFBFB),
  //   onBackground: Colors.black,
  //   error: _lightFillColor,
  //   onError: _lightFillColor,
  //   onPrimary: _lightFillColor,
  //   onSecondary: _darkFillColor,
  //   onSurface: Color(0xFFe0f2f1),
  //   brightness: Brightness.light,
  // );

  static const ColorScheme lightColorSchemeYellow = ColorScheme(
    // primary: Color(0xFFaebfbe),
    primary: Color(0xFFfafafa),
    primaryVariant: Color(0xFFc7c7c7),
    secondary: Color(0xFFfcd734),
    secondaryVariant: Color(0xFFc5a600),
    // background: Color(0xFFE6EBEB),
    background: primary,
    surface: primary,
    onBackground: Colors.black,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: _lightFillColor,
    onSurface: _lightFillColor,
    brightness: Brightness.light,
  );

  static const ColorScheme lightColorSchemeGudGreen = ColorScheme(
    // primary: Color(0xFFaebfbe),
    primary: Color(0xFFfafafa),
    primaryVariant: Color(0xFFc7c7c7),
    secondary: Color(0xFF15d683),
    secondaryVariant: Color(0xFF00a355),
    // background: Color(0xFFE6EBEB),
    background: primary,
    surface: primary,
    onBackground: Colors.black,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: _lightFillColor,
    onSurface: _lightFillColor,
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFF212121),
    primaryVariant: Color(0xFF1b1b1b),
    secondary: Color(0xFF15d683),
    secondaryVariant: Color(0xFF00a355),
    background: Color(0xFF1b1b1b),
    surface: Color(0xFF1b1b1b),
    onBackground: _darkFillColor, // White with 0.05 opacity
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _lightFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headline4: GoogleFonts.lato(
      fontWeight: _bold,
      fontSize: 20.0,
    ),
    caption: GoogleFonts.oswald(fontWeight: _semiBold, fontSize: 16.0),
    headline5: GoogleFonts.oswald(fontWeight: _medium, fontSize: 17.0),
    subtitle1: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 16.0),
    overline: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 12.0),
    bodyText1: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    subtitle2: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 14.0),
    bodyText2: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    headline6: GoogleFonts.montserrat(fontWeight: _bold, fontSize: 16.0),
    button: GoogleFonts.montserrat(fontWeight: _semiBold, fontSize: 14.0),
  );
}
