import 'dart:async';

import 'package:elephant/services/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textTheme = Theme.of(context).textTheme.headline2;
    // TODO: implement build
    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon1.png',
              height: 150,
            ),
            const Text('Elephant Powered by GudTech'),
            FutureBuilder<bool>(
              future: initializeAppData(controller),
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData) {
                  return const Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }
                timer(controller);
                // Navigator.of(context).pushNamed('/home');
                return Text(
                  'Welcome',
                  style: textTheme,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  timer(Controller controller) async {
    Timer(const Duration(seconds: 3), () {
      //this just detects if this action has been execuded previously
      if (!controller.navigateToHomeExecuted) {
        controller.navigateToHomeExecuted = true;
        Navigator.of(context).pushReplacementNamed('/');
      }
      // controller.notifyNoob();
    });
  }

  Future<bool> timerTest = Future<bool>.delayed(
    const Duration(seconds: 2),
    () => true,
  );

  Future<bool> initializeAppData(Controller controller) async {
    //userData starts in false but after the initialize data function it goes to true, this is so the function doesnt happen twice
    if (controller.userDataInitialized) return true;
    bool idk = await timerTest;
    await controller.initilizedUserData();

    return idk;
  }
}
