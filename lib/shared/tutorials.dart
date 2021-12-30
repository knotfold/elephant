import 'package:flutter/material.dart';

//this file is in charge of displaying tutorials to the user depending on the type of page they are on
//each tutorial is just composed of text for now, but they can be modified and perzonalized
class TutorialHome extends StatelessWidget {
  const TutorialHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Home Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text('In the home page you can explore'
            'the different glossaries that you have, and create new ones from 0. \n\n'
            'Click a glossary to navigate to its content. \n\n'
            'Or click the + button found on the down right corner to create a new glossary'),
        const SizedBox(height: 15),
        const Icon(Icons.face_retouching_natural),
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

class TutorialGlossary extends StatelessWidget {
  const TutorialGlossary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Glossary Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text(
            'In the glossary page first of all you will be able to see the list of terms'
            'that the current glossary has. \n\n\n'
            'The glossary option-navigator locatated at the bottom, is full of options that help you handle the different features of your glossary.\n\n'
            'If the glossary has no terms start adding some by clicking the add button down below in the'
            'navigation bar. \n\n'
            'The first button, with a band-aid icon takes you to a list of difficult terms.\n\n'
            'The second button with a play icon, takes you to the exam preparation page.\n\n'
            'The third button with the search icon, takes you to the search page where you can search a term in your list of terms helping you locate it faster. \n\n'
            'The fourth button takes you to the filter page, where you can add new tags and choose how to filter your list of terms. \n\n'
            'The fifth and maybe most important button is the add term button. where you can add new terms to your glossary. \n\n'
            'The last and biggest button contains the glossary general info. \n\n\n\n'
            'In this page once you have added terms you will be able to see them displayed on a list.\n\n'
            'Lastly you can edit a term by clicking their edit button on the right or add them to your favorites list by clicking the star button.\n\n'
            'If you want to delete a term, just slide it to the right and the delete button will showup'),
        const SizedBox(height: 15),
        const Icon(Icons.book),
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

class TutorialDifficultTerms extends StatelessWidget {
  const TutorialDifficultTerms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Glossary Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text(
            'In the difficult terms page, you can see all the terms that you could not answer correctly during your exams, this means'
            'that you struggle with this terms so they are in this special list.\n\n'
            'Having this special list should help you review and have a better understing of this terms.\n\n'
            'To remove them from this list you have to get them right on the difficult term exam which only contains open questions.\n\n'
            'Hope this feauture helps you memorize all this hard terms. :)'),
        const SizedBox(height: 15),
        const Icon(Icons.smart_toy_outlined),
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

class TutorialExamPreparationPage extends StatelessWidget {
  const TutorialExamPreparationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Glossary Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text(
            'In this page you can choose the settings that your exam will have.'
            'First of all you can choose the question and answer configuration this'
            'meaning that you can choose to test yourself using the terms like is originally intended,'
            'or you can use the answers as the question or a mix between terms and answers.\n\n'
            'Then you can choose the length of your exam, this means you can shorten the number of'
            'terms that you want to review/test in this session.\n\n'
            'Lastly are the buttons, just click the one with the option you would like to use in that moment.\n\n'
            'Have fun!'),
        const SizedBox(height: 15),
        const Icon(Icons.theater_comedy_outlined),
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

class TutorialFilterPage extends StatelessWidget {
  const TutorialFilterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Glossary Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text(
            'In this page you can filter your list on terms in different ways.\n\n'
            'First you can choose the option Use favorites, to only display all your favorites and exclude the ones that are not.'
            'The tags system is an interesting one because you can add your own tags and tag your terms individually. Once you have tagged your terms'
            'you can choose which tags you want your list of terms to display, so arrange your terms however you want :) \n\n'
            'Keep in mind that the filters do stack so the more tags you choose the larger your list will get, also the filtered list is the'
            'list that will be used during your test sessions so be careful choosing your tags.'),
        const SizedBox(height: 15),
        const Icon(Icons.airline_seat_recline_normal_rounded),
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

class TutorialThemePage extends StatelessWidget {
  const TutorialThemePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Glossary Page'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const Text(
            'In this page you can choose between the different themes that the app has to offer'
            'so you can feel in armony with the app theme while you study .\n\n'),
        const SizedBox(height: 15),
        const Icon(Icons.color_lens),
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
