import 'dart:async';

import 'package:elephant/services/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*page in charge of presenting the company info but specially in charge of loading the user info 
and intialize it like checking if a user its logged or if a user  has certain theme features selected*/
class NoConnectivityApp extends StatefulWidget {
  const NoConnectivityApp({Key? key}) : super(key: key);

  @override
  State<NoConnectivityApp> createState() => _NoConnectivityApp();
}

class _NoConnectivityApp extends State<NoConnectivityApp> {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textTheme = Theme.of(context).textTheme.headline2;
    return Scaffold(
      body: SizedBox(
        //makes the width of the page the width of the screen
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //displays the icon of elephant
              Image.asset(
                'assets/icon1.png',
                height: 150,
              ),
              const Icon(Icons.wifi_off_outlined),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Connection lost! \n'
                'check your internet connection and if that does not work, restart the app.',
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
