import 'package:elephant/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

//this is the theme of the app and im not gonna comment this for now
class GalleryThemeData {
  static const lightFillColor = Colors.black;
  static const darkFillColor = Colors.white;

  static final Color lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData =
      themeData(lightColorSchemeGudGreen, lightFocusColor);
  static ThemeData darkThemeData =
      themeData(darkColorSchemeGudGreen, darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme.copyWith(
        headline2: TextStyle(
            color: colorScheme.brightness == Brightness.dark
                ? darkFillColor
                : lightFillColor),
        headline3: TextStyle(
            color: colorScheme.brightness == Brightness.dark
                ? darkFillColor
                : lightFillColor),
        headline4: TextStyle(
            color: colorScheme.brightness == Brightness.dark
                ? darkFillColor
                : lightFillColor),
      ),
      // Matches manifest.json colors and background color.
      primaryColor: const Color(0xFF030303),
      appBarTheme: const AppBarTheme(
        elevation: 1,
        // iconTheme: IconThemeData(color: colorScheme.primary),
      ),

      switchTheme: SwitchThemeData(
          thumbColor:
              MaterialStateProperty.all<Color>(colorScheme.secondaryVariant),
          trackColor: MaterialStateProperty.all<Color>(colorScheme.secondary)),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: colorScheme.secondary,
          selectedItemColor: colorScheme.onSecondary,
          unselectedItemColor: colorScheme.onSecondary,
          unselectedIconTheme: IconThemeData(color: colorScheme.onSecondary)),

      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: colorScheme.secondary),

      radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all<Color>(colorScheme.secondary)),
      checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all<Color>(colorScheme.onSecondary),
          fillColor: MaterialStateProperty.all<Color>(colorScheme.secondary)),

      textSelectionTheme: TextSelectionThemeData(
          selectionColor: colorScheme.secondary,
          cursorColor: colorScheme.secondary),
      buttonBarTheme: const ButtonBarThemeData(
        buttonHeight: 15,
      ),
      // buttonTheme: const ButtonThemeData(colorScheme: ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
            colorScheme.secondary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
              color: colorScheme.brightness == Brightness.dark
                  ? darkFillColor
                  : lightFillColor),
          focusColor: colorScheme.primaryVariant,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.secondary)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.secondary),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          hintStyle: const TextStyle(color: sDark)),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          lightFillColor.withOpacity(0.80),
          darkFillColor,
        ),
        contentTextStyle: _textTheme.subtitle1?.apply(color: darkFillColor),
      ),
    );
  }

  //lightschemes
  static const ColorScheme lightColorSchemeBlue = ColorScheme(
    // primary: Color(0xFFaebfbe),
    primary: Color(0xFFfafafa),
    primaryVariant: Color(0xFFc7c7c7),
    secondary: Color(0xFF2196f3),
    secondaryVariant: Color(0xFF0069c0),
    // background: Color(0xFFE6EBEB),
    background: primary,
    surface: primary,
    onBackground: Colors.black,
    error: lightFillColor,
    onError: lightFillColor,
    onPrimary: lightFillColor,
    onSecondary: darkFillColor,
    onSurface: lightFillColor,
    brightness: Brightness.light,
  );

  static const ColorScheme lightColorSchemeOrange = ColorScheme(
    // primary: Color(0xFFaebfbe),
    primary: Color(0xFFfafafa),
    primaryVariant: Color(0xFFc7c7c7),
    secondary: Color(0xFFffcc80),
    secondaryVariant: Color(0xFFca9b52),
    // background: Color(0xFFE6EBEB),
    background: primary,
    surface: primary,
    onBackground: Colors.black,
    error: lightFillColor,
    onError: lightFillColor,
    onPrimary: lightFillColor,
    onSecondary: lightFillColor,
    onSurface: lightFillColor,
    brightness: Brightness.light,
  );

  static const ColorScheme lightColorSchemeYellow = ColorScheme(
    // primary: Color(0xFFaebfbe),
    primary: Color(0xFFfafafa),
    primaryVariant: Color(0xFFc7c7c7),
    secondary: Color(0xFFfcd734),
    tertiary: Color(0xFFc5a600),
    secondaryVariant: Color(0xFFc5a600),
    // background: Color(0xFFE6EBEB),
    background: primary,
    surface: primary,
    onBackground: Colors.black,
    error: lightFillColor,
    onError: lightFillColor,
    onPrimary: lightFillColor,
    onSecondary: lightFillColor,
    onSurface: lightFillColor,
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
    error: lightFillColor,
    onError: lightFillColor,
    onPrimary: lightFillColor,
    onSecondary: lightFillColor,
    onSurface: lightFillColor,
    brightness: Brightness.light,
  );

  /*


  */
  //darkschemes
  static const ColorScheme darkColorSchemeOrange = ColorScheme(
    primary: Color(0xFF212121),
    primaryVariant: Color(0xFF1b1b1b),
    secondary: Color(0xFFffcc80),
    secondaryVariant: Color(0xFFca9b52),
    background: Color(0xFF1b1b1b),
    surface: Color(0xFF1b1b1b),
    onBackground: darkFillColor, // White with 0.05 opacity
    error: darkFillColor,
    onError: Colors.red,
    onPrimary: darkFillColor,
    onSecondary: lightFillColor,
    onSurface: darkFillColor,
    brightness: Brightness.dark,
  );

  static const ColorScheme darkColorSchemeBlue = ColorScheme(
    primary: Color(0xFF212121),
    primaryVariant: Color(0xFF1b1b1b),
    secondary: Color(0xFF2196f3),
    secondaryVariant: Color(0xFF0069c0),
    background: Color(0xFF1b1b1b),
    surface: Color(0xFF1b1b1b),
    onBackground: darkFillColor, // White with 0.05 opacity
    error: darkFillColor,
    onError: Colors.red,
    onPrimary: darkFillColor,
    onSecondary: darkFillColor,
    onSurface: darkFillColor,
    brightness: Brightness.dark,
  );

  static const ColorScheme darkColorSchemeYellow = ColorScheme(
    primary: Color(0xFF212121),
    primaryVariant: Color(0xFF1b1b1b),
    secondary: Color(0xFFfcd734),
    secondaryVariant: Color(0xFFc5a600),
    background: Color(0xFF1b1b1b),
    surface: Color(0xFF1b1b1b),
    onBackground: darkFillColor, // White with 0.05 opacity
    error: darkFillColor,
    onError: darkFillColor,
    onPrimary: darkFillColor,
    onSecondary: lightFillColor,
    onSurface: darkFillColor,
    brightness: Brightness.dark,
  );

  static const ColorScheme darkColorSchemeGudGreen = ColorScheme(
    primary: Color(0xFF212121),
    primaryVariant: Color(0xFF1b1b1b),
    secondary: Color(0xFF15d683),
    secondaryVariant: Color(0xFF00a355),
    background: Color(0xFF1b1b1b),
    surface: Color(0xFF1b1b1b),
    onBackground: darkFillColor, // White with 0.05 opacity
    error: darkFillColor,
    onError: darkFillColor,
    onPrimary: darkFillColor,
    onSecondary: lightFillColor,
    onSurface: darkFillColor,
    brightness: Brightness.dark,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headline4: GoogleFonts.montserrat(
      fontWeight: _bold,
      fontSize: 16.0,
    ),
    //this roboto fontstyle is amazing, using letter spacing and the right fontweight does help
    headline1: GoogleFonts.roboto(
      fontWeight: FontWeight.w300,
      fontSize: 84.0,
      letterSpacing: -3.5,
    ),
    headline2: GoogleFonts.roboto(
        fontWeight: FontWeight.w200, fontSize: 64.0, letterSpacing: -1.5),
    headline3:
        GoogleFonts.montserrat(fontWeight: FontWeight.w200, fontSize: 20.0),

    caption: GoogleFonts.oswald(fontWeight: _semiBold, fontSize: 16.0),
    headline5: GoogleFonts.oswald(fontWeight: _medium, fontSize: 17.0),
    subtitle1: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 16.0),
    overline: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 12.0),
    bodyText1: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    subtitle2: GoogleFonts.montserrat(
        fontWeight: _regular, fontSize: 12.0, fontStyle: FontStyle.italic),
    bodyText2: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    headline6: GoogleFonts.montserrat(fontWeight: _bold, fontSize: 16.0),
    button: GoogleFonts.montserrat(fontWeight: _semiBold, fontSize: 14.0),
  );
}
