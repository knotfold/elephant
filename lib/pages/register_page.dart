import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //form key for the form used in the dialog
  final formKey = GlobalKey<FormState>();

  TextEditingController textEditingController = TextEditingController();

  late String userName;

  String snackBarText = 'Processing Data';

  int snackBarDuration = 10;

  bool userNameExists = false;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleTheme = Theme.of(context).textTheme.headline2;
    return Scaffold(
      appBar:
          myAppBar(context: context, type: 'register_page', title: 'Sign up'),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                'Registration page',
                style: textStyleTheme,
              ),
              const SizedBox(
                height: 45,
              ),
              TextFormField(
                controller: textEditingController,
                enabled: !controller.isLoading,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                ], //
                onSaved: (value) {
                  userName = value!.trim();
                },
                decoration: const InputDecoration(
                  labelText: 'User Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value.trim().contains(' ')) {
                    return 'Your username can not contain spaces';
                  }
                  if (userNameExists) {
                    return 'This username already exists';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 45,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading == true) return;

                  userNameExists = false;
                  print(textEditingController.text.toLowerCase().trim());
                  QuerySnapshot userNameChecker = await FirebaseFirestore
                      .instance
                      .collection('users')
                      .where('usernamePlain',
                          isEqualTo:
                              textEditingController.text.toLowerCase().trim())
                      .get();
                  if (userNameChecker.docs.isNotEmpty) {
                    print('username exists');
                    userNameExists = true;
                  }

                  // Validate returns true if the form is valid, or false otherwise.
                  if (formKey.currentState!.validate()) {
                    controller.isLoading = true;
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    formKey.currentState!.save();

                    controller.activeUser.username = userName;
                    controller.activeUser.usernamePlain =
                        userName.toLowerCase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: FutureBuilder<bool>(
                            future: controller.registerUser(context),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                snackBarDuration = 2;

                                return Text(snackBarText);
                              }

                              return const Text('Welcome to elephant');
                            }),
                        duration: Duration(seconds: snackBarDuration),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
