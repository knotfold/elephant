import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';

class ThemeChooserPage extends StatelessWidget {
  const ThemeChooserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: myAppBar(
          context: context, type: 'theme_chooser', title: 'Theme Chooser'),
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          Card(
            child: Column(
              children: [
                Text('Some theme name'),
                Container(
                  height: 10,
                  width: 10,
                  color: Colors.pink,
                )
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Text('Some theme name'),
                Container(
                  height: 10,
                  width: 10,
                  color: Colors.green,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
