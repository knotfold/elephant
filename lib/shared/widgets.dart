import 'package:elephant/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/pages/pages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

/*this files contains a lot of the widgets that are used in the app, specially widgets that can be used in 
  different instances of the app multiple times */

//the appbar widget is the most replicated one and it recieves a title, the context and the type on its constructor.
//the title is just a string to display as the title of the appbar
//and the type is an identifier of the page we are currently at
AppBar myAppBar(
    {String? title, required BuildContext context, required String type}) {
  Controller controller = Provider.of<Controller>(context);
  ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      color: colorScheme.background,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('Choose your exam type'),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navigateToDifficultExam(
                                    'difficultExam', context, controller);
                              },
                              child: const Text('    Exam    '),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                navigateToDifficultExam(
                                    'difficultFlashCards', context, controller);
                              },
                              child: const Text('Flash cards'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              // showDialog(
              //     context: context,
              //     builder: (context) {
              //       return SimpleDialog(
              //         children: [
              //           ButtonBar(
              //             children: [
              //               ElevatedButton(
              //                 onPressed: () {
              //                   navigateToDifficultExam(
              //                       'difficultExam', context, controller);
              //                 },
              //                 child: const Text('Exam'),
              //               ),
              //               ElevatedButton(
              //                 onPressed: () {
              //                   navigateToDifficultExam('difficultFlashCards',
              //                       context, controller);
              //                 },
              //                 child: const Text('Flash cards'),
              //               ),
              //             ],
              //           )
              //         ],
              //       );
              //     });

              icon: const Icon(Icons.play_circle_outline_outlined),
            )
          : Container(),
      type == 'libraryPage'
          ? IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: LibrarySearchDelegate(),
                );
              },
              icon: const Icon(Icons.search))
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
      const SizedBox(
        width: 10,
      ),
      controller.internetConnection
          ? Container()
          : const Icon(
              Icons.wifi_off,
              color: Colors.red,
            ),
      const SizedBox(
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
  controller.difficultTermList.shuffle();
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

class GlossaryInfo extends StatefulWidget {
  final GlossaryModel glossaryModel;
  const GlossaryInfo({Key? key, required this.glossaryModel}) : super(key: key);

  @override
  State<GlossaryInfo> createState() => _GlossaryInfoState();
}

class _GlossaryInfoState extends State<GlossaryInfo> {
  //recieves the main category that the glossary currently has

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Controller controller = Provider.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Card(
              child: SizedBox(
                width: 130,
                height: 150,
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
                              controller.currentGlossary.name,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            IconButton(
              iconSize: 50,
              onPressed: () {
                if (!controller.currentGlossary.glossaryUsers
                    .contains(controller.activeUser.username)) {
                  return;
                }
                showDialog(
                    context: context,
                    builder: (context) {
                      return DialogChangeMainCategory(
                        glossaryModel: widget.glossaryModel,
                      );
                    });
              },
              icon: Icon(
                controller.mainCategoryIconChooser(MainCategory.values
                    .firstWhere((element) =>
                        element.toString() ==
                        controller.currentGlossary.mainCategory)),
              ),
            ),
            Text(controller
                .mainCategoryToString(controller.currentGlossary.mainCategory)),
          ],
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
                  Expanded(
                    child: Text(
                        'Created by ' + controller.currentGlossary.creator),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.date_range),
                  ),
                  Expanded(
                      child: Text('On ' +
                          controller.timeStampToNormalDate(controller
                              .currentGlossary.creationDate
                              .toDate()
                              .toString()))),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.trip_origin,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      controller.currentGlossary.origin,
                    ),
                  ),
                ],
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     IconButton(
              //       onPressed: () {},
              //       icon: Icon(
              //         Icons.edit_attributes,
              //         color: colorScheme.secondary,
              //       ),
              //     ),
              //     Text('Main category: '),
              //     Text(controller.mainCategoryToString(
              //         controller.currentGlossary.mainCategory)),
              //   ],
              // ),
              const SizedBox(
                height: 47,
              ),
              GestureDetector(
                onTap: () {
                  if (widget.glossaryModel.creator ==
                      controller.activeUser.username) {
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return DialogRateGlossary(
                          glossaryModel: widget.glossaryModel,
                          currentUserRating: controller.ratingGivenByUser(),
                        );
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: controller.currentGlossary.rating >= 1
                          ? Colors.amber
                          : null,
                    ),
                    Icon(Icons.star,
                        color: controller.currentGlossary.rating >= 2
                            ? Colors.amber
                            : null),
                    Icon(Icons.star,
                        color: controller.currentGlossary.rating >= 3
                            ? Colors.amber
                            : null),
                    Icon(Icons.star,
                        color: controller.currentGlossary.rating >= 4
                            ? Colors.amber
                            : null),
                    Icon(Icons.star,
                        color: controller.currentGlossary.rating >= 5
                            ? Colors.amber
                            : null)
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text('Rating: ' +
                  controller.currentGlossary.rating.toString() +
                  '/5'),
            ],
          ),
        ),
      ],
    );
  }
}

class DialogChangeMainCategory extends StatefulWidget {
  final GlossaryModel glossaryModel;
  const DialogChangeMainCategory({Key? key, required this.glossaryModel})
      : super(key: key);

  @override
  State<DialogChangeMainCategory> createState() =>
      _DialogChangeMainCategoryState();
}

class _DialogChangeMainCategoryState extends State<DialogChangeMainCategory> {
  late String dropdownValueMainCategory = widget.glossaryModel.mainCategory;
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textThemeTilte = Theme.of(context).textTheme.headline5;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select the glossary main category',
              style: textThemeTilte,
            ),
            const SizedBox(
              height: 10,
            ),
            dropDownButtonGlossaryMainCategory(context),
            !controller.isLoading
                ? ButtonBar(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            controller.isLoading = true;
                            controller.notifyNoob();
                            await controller.currentGlossaryTransaction(() {
                              controller.currentGlossary.mainCategory =
                                  dropdownValueMainCategory;
                            });

                            controller.isLoading = false;
                            Navigator.of(context).pop();
                            controller.notifyNoob();
                          },
                          child: const Text('Update Main Category'))
                    ],
                  )
                : const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  Color dropDownTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  List<String> enumMainCategoryToList() {
    List<String> list = [];
    MainCategory.values.toList().forEach((element) {
      list.add(element.toString());
    });
    return list;
  }

  Padding dropDownButtonGlossaryMainCategory(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: dropdownValueMainCategory,
        style: TextStyle(color: dropDownTextColor(context)),
        icon: const Icon(Icons.arrow_downward),
        underline: Container(
          height: 2,
          color: primary,
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValueMainCategory = newValue!;
          });
        },
        items: enumMainCategoryToList()
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Icon(controller.mainCategoryIconChooser(MainCategory.values
                    .firstWhere((element) => element.toString() == value))),
                const SizedBox(
                  width: 10,
                ),
                Text(controller.mainCategoryToString(value)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DialogRateGlossary extends StatefulWidget {
  final GlossaryModel glossaryModel;
  final int currentUserRating;
  const DialogRateGlossary(
      {Key? key, required this.glossaryModel, required this.currentUserRating})
      : super(key: key);

  @override
  State<DialogRateGlossary> createState() => _DialogRateGlossaryState();
}

class _DialogRateGlossaryState extends State<DialogRateGlossary> {
  late String dropdownValueMainCategory = widget.glossaryModel.mainCategory;
  late int rating = widget.currentUserRating;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textThemeTilte = Theme.of(context).textTheme.headline5;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate the glossary',
              style: textThemeTilte,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.star,
                    color: rating >= 1 ? Colors.amber : null,
                  ),
                  onTap: () {
                    setState(() {
                      if (rating == 1) {
                        rating = 0;
                      } else {
                        rating = 1;
                      }
                    });
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.star,
                      color: rating >= 2 ? Colors.amber : null),
                  onTap: () {
                    setState(() {
                      if (rating == 2) {
                        rating = 0;
                      } else {
                        rating = 2;
                      }
                    });
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.star,
                      color: rating >= 3 ? Colors.amber : null),
                  onTap: () {
                    setState(() {
                      if (rating == 3) {
                        rating = 0;
                      } else {
                        rating = 3;
                      }
                    });
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.star,
                      color: rating >= 4 ? Colors.amber : null),
                  onTap: () {
                    setState(() {
                      if (rating == 4) {
                        rating = 0;
                      } else {
                        rating = 4;
                      }
                    });
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.star,
                      color: rating >= 5 ? Colors.amber : null),
                  onTap: () {
                    setState(() {
                      if (rating == 5) {
                        rating = 0;
                      } else {
                        rating = 5;
                      }
                    });
                  },
                )
              ],
            ),
            !controller.isLoading
                ? ButtonBar(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (widget.currentUserRating == rating) {
                              Fluttertoast.showToast(
                                  msg:
                                      'You did not change or choose your rating');
                              return;
                            }
                            controller.isLoading = true;
                            controller.notifyNoob();
                            await controller.currentGlossaryTransaction(() {
                              if (controller
                                  .currentGlossary.userRatings.isEmpty) {
                                controller.currentGlossary.userRatings.add({
                                  'user': controller.activeUser.username,
                                  'rating': rating,
                                });
                              } else {
                                bool notRated = true;
                                for (int i = 0;
                                    i <
                                        controller
                                            .currentGlossary.userRatings.length;
                                    i++) {
                                  if (controller.currentGlossary.userRatings[i]
                                          ['user'] ==
                                      controller.activeUser.username) {
                                    notRated = false;
                                    controller.currentGlossary.userRatings[i] =
                                        {
                                      'user': controller.activeUser.username,
                                      'rating': rating,
                                    };
                                  }
                                }
                                if (notRated) {
                                  controller.currentGlossary.userRatings.add({
                                    'user': controller.activeUser.username,
                                    'rating': rating,
                                  });
                                }
                              }

                              double newRating = 0;
                              for (var element
                                  in controller.currentGlossary.userRatings) {
                                newRating = newRating + element['rating'];
                              }
                              newRating = newRating /
                                  controller.currentGlossary.userRatings.length;

                              controller.currentGlossary.rating = newRating;
                            });

                            controller.isLoading = false;
                            Navigator.of(context).pop();
                            controller.notifyNoob();
                          },
                          child: const Text('Rate this glossary'))
                    ],
                  )
                : const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  Color dropDownTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  List<String> enumMainCategoryToList() {
    List<String> list = [];
    MainCategory.values.toList().forEach((element) {
      list.add(element.toString());
    });
    return list;
  }

  Padding dropDownButtonGlossaryMainCategory(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: dropdownValueMainCategory,
        style: TextStyle(color: dropDownTextColor(context)),
        icon: const Icon(Icons.arrow_downward),
        underline: Container(
          height: 2,
          color: primary,
        ),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValueMainCategory = newValue!;
          });
        },
        items: enumMainCategoryToList()
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Icon(controller.mainCategoryIconChooser(MainCategory.values
                    .firstWhere((element) => element.toString() == value))),
                const SizedBox(
                  width: 10,
                ),
                Text(controller.mainCategoryToString(value)),
              ],
            ),
          );
        }).toList(),
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
  final String route;
  const GlossaryCard({
    Key? key,
    required this.glossary,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final authorTextTheme = Theme.of(context).textTheme.subtitle2;

    return GestureDetector(
      onTap: () {
        controller.useFavoriteTerms = false;
        controller.resetControllerVars();
        controller.currentGlossary = glossary;

        Navigator.of(context).pushNamed(route);
      },
      child: SizedBox(
        width: 135,
        height: 150,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(glossary.origin.trim() == 'Original' ||
                            glossary.origin == ''
                        ? Icons.trip_origin
                        : Icons.file_copy),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.book,
                      size: 30,
                    ),
                  ],
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
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'By ' + glossary.creator,
                  style: authorTextTheme,
                )

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
