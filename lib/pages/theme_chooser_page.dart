import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:provider/provider.dart';
import 'package:elephant/themes/app_main_theme.dart';
import 'package:elephant/shared/colors.dart';

class ThemeChooserPage extends StatelessWidget {
  const ThemeChooserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        return controller.isLoading ? false : true;
      },
      child: Scaffold(
        appBar: myAppBar(
            context: context, type: 'theme_chooser', title: 'Theme Chooser'),
        body: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          children: [
            CardThemeChooser(
              controller: controller,
              themeName: 'Greelephant',
              color: gudGreen,
            ),
            CardThemeChooser(
                controller: controller,
                themeName: 'Bluelephant',
                color: bluelephant),
            CardThemeChooser(
              controller: controller,
              themeName: 'Yellowphant',
              color: yellowPhant,
            ),
            CardThemeChooser(
              controller: controller,
              themeName: 'Orangephant',
              color: orangephant,
            )
          ],
        ),
      ),
    );
  }
}

class CardThemeChooser extends StatelessWidget {
  final String themeName;
  final Color color;

  const CardThemeChooser(
      {Key? key,
      required this.controller,
      required this.themeName,
      required this.color})
      : super(key: key);

  final Controller controller;

  @override
  Widget build(BuildContext context) {
    ColorScheme light;
    ColorScheme dark;
    switch (themeName) {
      case 'Yellowphant':
        light = GalleryThemeData.lightColorSchemeYellow;
        dark = GalleryThemeData.darkColorSchemeYellow;
        break;
      case 'Bluelephant':
        light = GalleryThemeData.lightColorSchemeBlue;
        dark = GalleryThemeData.darkColorSchemeBlue;
        break;
      case 'Greelephant':
        light = GalleryThemeData.lightColorSchemeGudGreen;
        dark = GalleryThemeData.darkColorSchemeGudGreen;
        break;
      case 'Orangephant':
        light = GalleryThemeData.lightColorSchemeOrange;
        dark = GalleryThemeData.darkColorSchemeOrange;
        break;
      default:
        light = GalleryThemeData.lightColorSchemeGudGreen;
        dark = GalleryThemeData.darkColorSchemeGudGreen;
        break;
    }
    return GestureDetector(
      onTap: () async {
        if (!controller.isLoading) {
          controller.isLoading = true;
          await controller.onSelectTheme(light, dark, themeName);
          Navigator.of(context).pushNamed('/');
          controller.isLoading = false;
        }
      },
      child: Card(
        child: Column(
          children: [
            Text(themeName),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 100,
              width: 100,
              color: color,
            )
          ],
        ),
      ),
    );
  }
}
