import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  //form key for the form used in the dialog
  final formKey = GlobalKey<FormState>();

  RegisterPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          myAppBar(context: context, type: 'register_page', title: 'Sign up'),
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'User'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
