import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';

//widget in charge of displaying a bunch of settings to the user
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context: context, type: 'settings', title: 'Settings'),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/themeChooserPage');
            },
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
          ),
          ListTile(
            leading: const Icon(Icons.tablet_sharp),
            title: const Text('TestWidget'),
            onTap: () {
              Navigator.of(context).pushNamed('/widgetTester');
            },
          ),
        ],
      ),
    );
  }
}
