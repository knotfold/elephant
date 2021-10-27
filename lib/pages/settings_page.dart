import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
          )
        ],
      ),
    );
  }
}
