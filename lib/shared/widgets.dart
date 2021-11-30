import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/pages/pages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

AppBar myAppBar(
    {String? title, required BuildContext context, required String type}) {
  Controller controller = Provider.of<Controller>(context);
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  return AppBar(
    leading: type == 'home'
        ? const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image(
              image: AssetImage('assets/icon1.png'),
            ),
          )
        : null,
    title: Text(title ?? 'Elephant'),
    actions: [
      type == 'home'
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settingsPage');
              },
              icon: const Icon(Icons.settings_applications_outlined))
          : Container(),
      type == 'Difficult Terms'
          ? IconButton(
              onPressed: () {
                navigateToDifficultExam('difficultExam', context, controller);
              },
              icon: const Icon(Icons.play_circle_outline_outlined),
            )
          : Container(),
      IconButton(
          onPressed: () {
            Widget toShowDialog;
            switch (type) {
              case 'home':
                toShowDialog = TutorialHome();
                break;

              default:
                toShowDialog = SimpleDialog();
                break;
            }
            showDialog(context: context, builder: (context) => toShowDialog);
          },
          icon: const Icon(Icons.help_outline_rounded)),
    ],
  );
}

navigateToDifficultExam(
  String type,
  BuildContext context,
  Controller controller,
) {
  controller.resetControllerVars();

  controller.generateDifficultTermList();
  Navigator.of(context).pop();
  Navigator.of(context).pushNamed(ExamPage.routeName,
      arguments: ExamArguments(
        examType: type,
      ));
}

class ListTileTerm extends StatelessWidget {
  const ListTileTerm({
    Key? key,
    required this.term,
    required this.controller,
  }) : super(key: key);

  final TermModel term;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return DialogAddNewTerm(
                        term: term,
                        emptyTerm: false,
                        termBackUp: term.term,
                      );
                    });
              },
              icon: const Icon(Icons.edit_outlined)),
          // IconButton(
          //   onPressed: () {
          //     showDialog(
          //         context: context,
          //         builder: (context) {
          //           return AlertDialog(
          //             title: const Text(
          //                 'Are you sure you want to delete this term?'),
          //             actions: [
          //               ElevatedButton(
          //                   onPressed: () {
          //                     Navigator.of(context).pop();
          //                   },
          //                   child: const Text('Cancel')),
          //               ElevatedButton(
          //                   onPressed: () async {
          //                     await controller
          //                         .currentGlossaryDocuments[index].reference
          //                         .delete();
          //                     Navigator.of(context).pop();
          //                   },
          //                   child: const Text('Delete'))
          //             ],
          //           );
          //         });
          //   },
          //   icon: const Icon(Icons.delete_forever_rounded),
          // )
          IconButtonFavoriteTerm(controller: controller, term: term)
        ],
      ),
      // leading: Icon(controller.termIconAsignner(term.type)),
      title: Text(term.term),
      subtitle: Text(term.answer),
    );
  }
}

class ErrorConnection extends StatelessWidget {
  const ErrorConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Column(
        children: const [
          Icon(
            Icons.error,
            size: 50,
            color: Colors.red,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'An error has occured while loading the data, check your wifi connection.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CheckBoxListTags extends StatelessWidget {
  const CheckBoxListTags({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.currentGlossary.tags.length,
        itemBuilder: (context, index) {
          String tag = controller.currentGlossary.tags[index];
          return CheckboxListTile(
              title: Text(tag),
              value: controller.checkTagSelected(tag),
              onChanged: (bool? value) {
                if (!value!) {
                  controller.selectedTags.remove(tag);
                } else {
                  controller.selectedTags.add(tag);
                }

                controller.notifyNoob();
              });
        });
  }
}

class GlossaryCard extends StatelessWidget {
  final GlossaryModel glossary;
  const GlossaryCard({
    Key? key,
    required this.glossary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        controller.useFavoriteTerms = false;
        controller.resetControllerVars();
        controller.currentGlossary = glossary;
        Navigator.of(context).pushNamed('/glossaryPage');
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.book,
                size: 30,
              ),
              const SizedBox(
                height: 15,
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                    glossary.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ),

              // const Icon(
              //   Icons.menu_book,
              //   size: 0,
              //   color: pDark,
              // )
              // const Image(
              //   fit: BoxFit.fitHeight,
              //   image: AssetImage('assets/elebaby.png'),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class TermTypeDisplayText extends StatelessWidget {
  const TermTypeDisplayText({
    Key? key,
    required this.colorScheme,
    required this.controller,
    required this.widget,
    required this.textStyleTermType,
  }) : super(key: key);

  final ColorScheme colorScheme;
  final Controller controller;
  final FlashCard widget;
  final TextStyle? textStyleTermType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: colorScheme.onBackground),
      ),
      child: Text(
        controller.termTypeToString(widget.term),
        style: textStyleTermType,
      ),
    );
  }
}
