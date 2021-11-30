import 'package:flutter/material.dart';

class TutorialHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SimpleDialog(
      title: const Text('Home Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text('In the home page you can explore'
            'the different glossaries that you have, and create new ones from 0. \n\n'
            'Click a glossary to navigate to its content. \n\n'
            'Or click the + button found on the down right corner to create a new glossary'),
        const SizedBox(height: 15),
        Icon(Icons.face_retouching_natural),
        const SizedBox(height: 15),
        ButtonBar(
          children: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go back'))
          ],
        )
      ],
    );
  }
}
