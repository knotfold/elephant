import 'package:elephant/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/pages/pages.dart';
import 'package:provider/provider.dart';

/*this files contains a lot of the widgets that are used in the app, specially widgets that can be used in 
  different instances of the app multiple times */

//the appbar widget is the most replicated one and it recieves a title, the context and the type on its constructor.
//the title is just a string to display as the title of the appbar
//and the type is an identifier of the page we are currently at
AppBar myAppBar(
    {String? title, required BuildContext context, required String type}) {
  Controller controller = Provider.of<Controller>(context);
  //depending on the type of the page the appbar displays different options
  return AppBar(
    //if the type is home, then it shows the icon of the app
    leading: type == 'home'
        ? const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image(
              image: AssetImage('assets/icon1.png'),
            ),
          )
        : null,
    //it always displays the title recieved in the constructor and if it happens to be null
    //just displays the name of the app
    title: Text(title ?? 'Elephant'),
    actions: [
      //if the type is home it show a button to navigate to the settingspage
      type == 'home'
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settingsPage');
              },
              icon: const Icon(Icons.settings_applications_outlined))
          : Container(),
      /*if the type is difficult terms, it shows a special button that lets you navigate to the difficult exam*/
      type == 'Difficult Terms'
          ? IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        children: [
                          ButtonBar(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  navigateToDifficultExam(
                                      'difficultExam', context, controller);
                                },
                                child: const Text('Exam'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  navigateToDifficultExam('difficultFlashCards',
                                      context, controller);
                                },
                                child: const Text('Flash cards'),
                              ),
                            ],
                          )
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.play_circle_outline_outlined),
            )
          : Container(),
      /*this last action is used to display an iconbutton that leads you to the tutorial dialog, based on the 
      page type it displays the right tutorial*/
      IconButton(
          onPressed: () {
            Widget toShowDialog;
            switch (type) {
              case 'themeChooser':
                toShowDialog = const TutorialThemePage();
                break;
              case 'filterTermsPage':
                toShowDialog = const TutorialFilterPage();
                break;
              case 'examSettings':
                toShowDialog = const TutorialExamPreparationPage();
                break;
              case 'Difficult Terms':
                toShowDialog = const TutorialDifficultTerms();
                break;
              case 'glossary':
                toShowDialog = const TutorialGlossary();
                break;
              case 'home':
                toShowDialog = const TutorialHome();
                break;

              default:
                toShowDialog = const SimpleDialog();
                break;
            }
            showDialog(context: context, builder: (context) => toShowDialog);
          },
          icon: const Icon(Icons.help_outline_rounded)),
      SizedBox(
        width: 10,
      ),
      controller.internetConnection
          ? Container()
          : Icon(
              Icons.wifi_off,
              color: Colors.red,
            ),
      SizedBox(
        width: 10,
      ),
    ],
  );
}

/*function used to navigate to the difficult exam and it also resets some of the controller vars for proper utilization
and also generates a difficulttermlist which is the one to be used in the exam*/
navigateToDifficultExam(
  String type,
  BuildContext context,
  Controller controller,
) {
  controller.resetControllerVars();

  controller.generateDifficultTermList();
  Navigator.of(context).pop();
  Navigator.of(context).pop();
  Navigator.of(context).pushNamed(ExamPage.routeName,
      arguments: ExamArguments(
        examType: type,
      ));
}

/*displays the term in a list tile this is used in a lot of places of the app
so modfiying it influences a lot of the app, gotta be careful, it has a lot of advantages
but might be sacrifice some customization*/
class ListTileTerm extends StatelessWidget {
  const ListTileTerm({
    Key? key,
    required this.term,
    required this.controller,
  }) : super(key: key);

  //recieves the term to be displayed as its constructor
  final TermModel term;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //idk what is the visual denstity for, i think it makes the tile more wide
      visualDensity: const VisualDensity(horizontal: -4),
      //content padding lol
      contentPadding: const EdgeInsets.all(2),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*this button is the edit button and is in charge of displaying the edit dialog this time the dialog recieves 
          the term in the constructor which means that it is not an empty term and this makes the dialog show different options
          and execute different functions it is crucial to set the emptyterm bool to false so the correct options are displayed */
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
          IconButtonFavoriteTerm(controller: controller, term: term)
        ],
      ),
      /*the leading can show 2 options based on the sorting order chosen by the user*/
      leading: Text(
        controller.orderAlphabetically
            ? term.term.characters.first
            : (term.listIndex + 1).toString(),
      ),
      title: Text(term.term),
      subtitle: Text(term.answer),
    );
  }
}

//this widget is used to display errors in the app, this needs to be further modified to make it look more profesional
class ErrorConnection extends StatelessWidget {
  const ErrorConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

//this checkboxlistags is used to add and remove tags from the currently selected filters
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

/*this is the card displaying on the homepage of the app and displays the glossaries, it is fair to say im not 
tet convinced about this widget style */
class GlossaryCard extends StatelessWidget {
  final GlossaryModel glossary;
  const GlossaryCard({
    Key? key,
    required this.glossary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        controller.useFavoriteTerms = false;
        controller.resetControllerVars();
        controller.currentGlossary = glossary;
        Navigator.of(context).pushNamed('/glossaryPage');
      },
      child: Card(
        color: colorScheme.background,
        elevation: 0,
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
                  height: 50,
                  width: 150,
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

/*this widget takes the term type and just displays the text in a cool stlye, for example the Type.adjective would be
just returned as adjective which makes it look cooler and better*/
class TermTypeDisplayText extends StatelessWidget {
  const TermTypeDisplayText({
    Key? key,
    required this.termModel,
  }) : super(key: key);

  final TermModel termModel;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleTermType = Theme.of(context).textTheme.subtitle2;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: colorScheme.onBackground),
      ),
      child: Text(
        controller.termTypeToString(termModel),
        style: textStyleTermType,
      ),
    );
  }
}
