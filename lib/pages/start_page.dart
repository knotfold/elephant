import 'dart:async';

import 'package:elephant/services/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*page in charge of presenting the company info but specially in charge of loading the user info 
and intialize it like checking if a user its logged or if a user  has certain theme features selected*/
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
    print('we got to the starter page :)');
    return Scaffold(
      body: SizedBox(
        //makes the width of the page the width of the screen
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //displays the icon of elephant
            Image.asset(
              'assets/icon1.png',
              height: 150,
            ),
            const Text('Elephant Powered by GudTech'),
            //future in charge of initializing the user data
            FutureBuilder<bool>(
              //futurue function
              future: initializeAppData(controller),
              builder: (context, asyncSnapshot) {
                //if the snapshot does not have data, it means it is still loading
                if (!asyncSnapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }
                //timer to navigate after some seconds
                timer(controller);
                // Navigator.of(context).pushNamed('/home');
                //if the snapshot has data show the welcome text
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

  //timer in charge of navigating after a set amount of times
  timer(Controller controller) async {
    Timer(const Duration(seconds: 3), () {
      //this just detects if this action has been execuded previously
      if (!controller.navigateToHomeExecuted) {
        controller.navigateToHomeExecuted = true;
        Navigator.of(context).pop();
      }
      // controller.notifyNoob();
    });
  }

  //timer test function
  Future<bool> timerTest = Future<bool>.delayed(
    const Duration(seconds: 2),
    () => true,
  );

  //initializeAppData means this function is in charge of initializing the user data
  Future<bool> initializeAppData(Controller controller) async {
    //userData starts in false but after the initialize data function it goes to true, this is so the function doesnt happen twice
    if (controller.userDataInitialized) return true;
    bool idk = await timerTest;
    //this function is gonna be very important in the future
    await controller.initilizedUserData();

    return idk;
  }
}
