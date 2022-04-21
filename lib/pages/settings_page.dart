import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

//widget in charge of displaying a bunch of settings to the user
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      appBar: myAppBar(context: context, type: 'settings', title: 'Settings'),
      body: ListView(
        children: [
          ListTile(
            trailing: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('You are about to log out'),
                        actions: [
                          OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          ElevatedButton(
                              onPressed: () {
                                controller.logout(context);
                              },
                              child: const Text('Yes, log out'))
                        ],
                      );
                    });
              },
            ),
            // leading: const Icon(Icons.face),
            title: Text(controller.activeUser.username),
            subtitle: const Text('Hi :), The text above is your id'),
          ),
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
