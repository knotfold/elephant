import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:provider/provider.dart';
import 'package:elephant/themes/app_main_theme.dart';
import 'package:elephant/shared/colors.dart';

//this page is in charge of letting the user choose the desired team for the app
class ThemeChooserPage extends StatelessWidget {
  const ThemeChooserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    //doesn't let the scope to be poped if something is loading
    return WillPopScope(
      onWillPop: () async {
        return controller.isLoading ? false : true;
      },
      child: Scaffold(
        appBar: myAppBar(
            context: context, type: 'themeChooser', title: 'Theme Chooser'),
        //displays the current avaliables themes for the app
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

//card for in charge of displaying the theme info
class CardThemeChooser extends StatelessWidget {
  //recieves the themeName to later be used in a switch to assign the right colors to the theme
  final String themeName;
  //recieves the color to be used as a secondary color
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ColorScheme light;
    ColorScheme dark;
    //this switch is in charge of giving the right colors to the theme depending on the theme name
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
    //gesture detector so the card can be clicked and the theme selected
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
        color: colorScheme.background,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              themeName,
              style: TextStyle(fontSize: 18),
            ),
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
