import 'package:elephant/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textTheme = Theme.of(context).textTheme.headline6;
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
            Text(
              'Elephant Powered by GudTech',
              style: textTheme,
            ),
            const SizedBox(
              height: 35,
            ),
            !controller.isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SignInButton(
                        Buttons.Facebook,
                        onPressed: () async {
                          await signInWithFacebook(controller, context);
                        },
                      ),
                      SignInButton(Buttons.Google, onPressed: () async {
                        await signInWithGoogle(controller, context);
                      }),
                      SignInButton(Buttons.Apple, onPressed: () {})
                    ],
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

Future<UserCredential> signInWithGoogle(
    Controller controller, BuildContext context) async {
  controller.isLoading = true;
  controller.notifyNoob();
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance
      .signInWithCredential(credential)
      .onError((error, stackTrace) {
    controller.isLoading = false;
    throw error.toString();
  }).then((value) {
    if (value.user!.uid.isNotEmpty) {
      controller.isLoading = false;
      controller.login(value.user!, context);
      return value;
    } else {
      controller.isLoading = false;
      return value;
    }
  });
}

Future<UserCredential> signInWithFacebook(
    Controller controller, BuildContext context) async {
  controller.isLoading = true;
  controller.notifyNoob();
  //This will let the shared preferences the type of login to use
  LoginType loginType = LoginType.facebook;
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
    controller.isLoading = false;
    throw error.toString();
  }).then((value) {
    if (value.user!.uid.isNotEmpty) {
      controller.isLoading = false;

      controller.login(value.user!, context);
      return value;
    } else {
      controller.isLoading = false;
      return value;
    }
  });
}
