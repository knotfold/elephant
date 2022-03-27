import 'package:elephant/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textTheme = Theme.of(context).textTheme.headline2;
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
            SignInButton(
              Buttons.Facebook,
              onPressed: () async {
                await signInWithFacebook(controller, context);
              },
            )
          ],
        ),
      ),
    );
  }
}

Future<UserCredential> signInWithFacebook(
    Controller controller, BuildContext context) async {
  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();

  if (loginResult.status == LoginStatus.success) {
    // you are logged

    final AccessToken accessToken = loginResult.accessToken!;
  } else {
    print(loginResult.status);
    print(loginResult.message);
  }

  // Create a credential from the access token
  final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential)
      .onError((error, stackTrace) {
    throw error.toString();
  }).then((value) {
    if (value.user!.uid.isNotEmpty) {
      controller.login(value.user!, context);
      return value;
    } else {
      return value;
    }
  });
}
