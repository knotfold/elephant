import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';

//the glossary page is in charge of displaying the current glossary selected by the user
//it displays the glossary terms in a list and also it displays different info from the
//glossary in the navbar sheet, also the navbar has many options for the user to use and
//interect with the different features of the glossary
class GlossaryPage extends StatefulWidget {
  const GlossaryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  //controller for the bottom nav bar
  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);
  @override
  void initState() {
    /*listener that contains the different features of the navbar, when an item of the
    nav bar is clicked it  the listener recieves its index and with a switch it executes an option
    depending on the index selected*/
    _bottomBarController.itemsStream.listen((index) {
      Future.delayed(Duration.zero, () {
        switch (index) {
          case 0:
            //navigates to the difficult terms page
            navigateToDifficultTerms(context);
            break;
          case 1:
            //navigates to the exam settings page
            Navigator.of(context).pushNamed('/examSettingsPage');

            break;
          case 2:
            //navigates to the search page
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(),
            );
            break;
          case 3:
            //navaigates to the filter page
            Navigator.of(context).pushNamed('/filterGlossaryTermsPage');
            break;
          case 4:
            /*shows a dialog that allows the user to add a new term, the add new term dialog requires a 
            termmodel so for this option we just pass an empty term  */
            showDialog(
              context: context,
              builder: (context) => DialogAddNewTerm(
                term:
                    TermModel('', '', Type.values.first.toString(), 'untagged'),
                emptyTerm: true,
              ),
            );
            break;
          default:
            //the default of the switch is to show the add dialog, but this should never happen
            showDialog(
              context: context,
              builder: (context) => DialogAddNewTerm(
                term:
                    TermModel('', '', Type.values.first.toString(), 'untagged'),
                emptyTerm: true,
              ),
            );
            break;
        }
      });
    });
    super.initState();
  }

  //navigates to the difficult terms page
  navigateToDifficultTerms(BuildContext context) {
    Controller controller = Provider.of<Controller>(context, listen: false);
    //generates the difficult term list
    controller.generateDifficultTermList();
    Navigator.of(context).pushNamed('/difficultTermsPage');
  }

  //text editing controller for the delete glossary part

  TextEditingController textEditingControllerDeleteGlossary =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Controller controller = Provider.of<Controller>(context);
    //stream of the current glossary to monitor it from the database
    final Stream<DocumentSnapshot> _glossaryStream =
        controller.currentGlossary.documentReference.snapshots();

    return WillPopScope(
      onWillPop: () async {
        //clears the selecttags and resets some controller vars
        controller.selectedTags.clear();
        controller.resetControllerVars();

        return true;
      },
      child: Scaffold(
        bottomNavigationBar: BottomBarWithSheet(
          onSelectItem: (index) {},
          mainActionButtonTheme: MainActionButtonTheme(
              icon: Icon(
                Icons.settings,
                color: colorScheme.onSecondary,
              ),
              color: colorScheme.secondary),
          bottomBarTheme: bottomBarTheme(context),
          sheetChild: BottomNavBarSheetBody(
              controller: controller,
              textEditingControllerDeleteGlossary:
                  textEditingControllerDeleteGlossary),
          controller: _bottomBarController,
          items: const [
            BottomBarWithSheetItem(icon: Icons.healing_rounded),
            BottomBarWithSheetItem(icon: Icons.play_circle_outline_outlined),
            BottomBarWithSheetItem(icon: Icons.search),
            BottomBarWithSheetItem(icon: Icons.filter_list),
            BottomBarWithSheetItem(icon: Icons.add_circle_outline),
          ],
        ),
        appBar: myAppBar(
            title: controller.currentGlossary.name,
            context: context,
            type: 'glossary'),
        body: controller.isLoading
            ? const CircularProgressIndicator()
            : ListViewTermsSB(
                glossaryStream: _glossaryStream, controller: controller),
      ),
    );
  }

  //theme of the bottombar

  BottomBarTheme bottomBarTheme(BuildContext context) {
    return BottomBarTheme(
      heightOpened: 600,
      itemIconColor: Theme.of(context).colorScheme.onBackground,
      selectedItemIconColor: Theme.of(context).colorScheme.onBackground,
      mainButtonPosition: MainButtonPosition.right,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
      ),
    );
  }
}

/*this is the body of this page and contains a streambuilder that constantly monitors the current
glossary snapshots, and displays the list of terms that the current glossary has*/
class ListViewTermsSB extends StatelessWidget {
  const ListViewTermsSB({
    Key? key,
    required Stream<DocumentSnapshot<Object?>> glossaryStream,
    required this.controller,
  })  : _glossaryStream = glossaryStream,
        super(key: key);

  final Stream<DocumentSnapshot<Object?>> _glossaryStream;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _glossaryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          controller.currentGlossary =
              GlossaryModel.fromDocumentSnapshot(snapshot.data!);

          if (controller.currentGlossary.termsMapList.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'This glossary does not contain any terms at all or with the current applied filters, would you like to add some to it? Click the add button down below',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          controller.mapListToTermsList();

          //TODO: test this
          if (controller.currentGlossary.usersInExamList.contains('user')) {
            controller.currentGlossaryTransaction(() {
              controller.currentGlossary.usersInExamList.remove('user');
            });
          }

          return ListViewBuilderTerms(
            controller: controller,
          );
        });
  }
}

//this is the body of the bottom nav bar, and contains the glossary info
//and also gives the user the oportunity to delete the glossary :(
//it also show a dialog to confirm and warn the user of the possible mistake of deleting info
class BottomNavBarSheetBody extends StatelessWidget {
  const BottomNavBarSheetBody({
    Key? key,
    required this.controller,
    required this.textEditingControllerDeleteGlossary,
  }) : super(key: key);

  final Controller controller;
  final TextEditingController textEditingControllerDeleteGlossary;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 10,
          ),
          GlossaryInfo(
            glossaryModel: controller.currentGlossary,
          ),
          const SizedBox(
            height: 25,
          ),
          const Divider(
            thickness: 1,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Delete Glossary:\n\n'
            'To delete this glossary you need to write the glossary name as you registered.',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
          const SizedBox(
            height: 25,
          ),
          TextFormField(
            controller: textEditingControllerDeleteGlossary,
            decoration: const InputDecoration(
              labelText: 'Glossary name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
          ),
          ButtonBar(
            children: [
              OutlinedButton(
                  onPressed: () {
                    if (controller.currentGlossary.name ==
                        textEditingControllerDeleteGlossary.text.trim()) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                  'Are you sure you want to delete this glossary forever?'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.warning),
                                  Text(
                                      '¡Keep in mind that once a  glossary is deleted it can not be recovered and can end up being a mistake!'),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    controller.isLoading = true;
                                    controller.notifyNoob();
                                    await controller
                                        .currentGlossary.documentReference
                                        .delete();
                                    controller.isLoading = false;

                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Yes, delete forever'),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            );
                          });
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Wrong name',
                      );
                    }
                  },
                  child: const Text('Delete glossary forever'))
            ],
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable

// ignore: must_be_immutable
//this is the list that displays the terms of the glossary
class ListViewBuilderTerms extends StatelessWidget {
  const ListViewBuilderTerms({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final Controller controller;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleHeadline = Theme.of(context).textTheme.headline5;

    List<TermModel> termsList = controller.listAssignerFunction();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Container(),
            title: Text(
              'Terms ${termsList.length}',
              textAlign: TextAlign.start,
              style: textStyleHeadline,
            ),
          ),
          //instead of a listview builder a special customscrolliview with a sliverlist is used
          //seems to be working pretty pretty good
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                TermModel term = termsList[index];
                if (index > termsList.length) return null;
                return Slidable(
                  direction: Axis.horizontal,
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        label: 'Delete',
                        icon: Icons.delete_forever,
                        onPressed: (BuildContext context) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return controller
                                      .currentGlossary.usersInExamList.isEmpty
                                  ? WillPopScope(
                                      onWillPop: () async {
                                        return !controller.isLoading;
                                      },
                                      child: AlertDialog(
                                        title: const Text(
                                            'Are you sure you want to delete this term?'),
                                        actions: controller.isLoading
                                            ? [
                                                const CircularProgressIndicator()
                                              ]
                                            : [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                                ElevatedButton(
                                                    onPressed: () async {
                                                      controller.isLoading =
                                                          true;
                                                      controller.notifyNoob();
                                                      controller.currentGlossary
                                                          .termsMapList
                                                          .removeAt(
                                                              term.listIndex);
                                                      await controller
                                                          .currentGlossary
                                                          .documentReference
                                                          .update(controller
                                                              .currentGlossary
                                                              .toMap())
                                                          .catchError((onError) =>
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          'Error, could not delete the term'))
                                                          .then((value) =>
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          'Term deleted succesfully'));
                                                      Navigator.of(context)
                                                          .pop();
                                                      controller.isLoading =
                                                          false;
                                                    },
                                                    child: const Text('Delete'))
                                              ],
                                      ),
                                    )
                                  : const SimpleDialog(
                                      contentPadding: EdgeInsets.all(15),
                                      children: [
                                        Text(
                                            'Someone is in exam, wait for his/her exam to finish in order to edit or add terms')
                                      ],
                                    );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  child: ListTileTerm(term: term, controller: controller),
                );
              },
              childCount: termsList.length,
            ),
          ),
        ],
      ),
    );
  }
}

/* this button is special and it is used in a lot of the instances where the
terms are displayed. this buttons handles the favorite status of a term */
class IconButtonFavoriteTerm extends StatelessWidget {
  const IconButtonFavoriteTerm({
    Key? key,
    required this.controller,
    required this.term,
  }) : super(key: key);

  final Controller controller;
  final TermModel term;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          //Add to favs
          handleFavoritesLogic();
        },
        icon: Icon(
          term.isFavorite ? Icons.star : Icons.star_border,
          color: term.isFavorite
              ? Colors.amber
              : Theme.of(context).colorScheme.onBackground,
        ));
  }

  handleFavoritesLogic() async {
    //if the controller is loading it just returns so the orders given by the user dont get stacked
    if (controller.isLoading) {
      return;
    }
    //first thing to do is set the controller is loading to true to not let the user q more petitions
    controller.isLoading = true;
    /* /cheks if the item is already favorite or not, depending if it is or not it adds it or removes it from the favorites 
    list and then proceeds to update the whole glossary*/

    if (term.isFavorite) {
      term.favoritesList.remove('user');
      controller.currentGlossary.termsMapList[term.listIndex] = term.toMap();
      await controller.currentGlossary.documentReference
          .update(controller.currentGlossary.toMap())
          .then((value) {
        term.isFavorite = false;
        Fluttertoast.showToast(msg: 'Removed from favorites');
      }).catchError((onError) {
        Fluttertoast.showToast(msg: 'Error, could not remove favorite');
      });
    } else {
      term.favoritesList.add('user');
      controller.currentGlossary.termsMapList[term.listIndex] = term.toMap();
      await controller.currentGlossary.documentReference
          .update(controller.currentGlossary.toMap())
          .then((value) {
        term.isFavorite = false;
        Fluttertoast.showToast(msg: 'Added to favorites');
      }).catchError((onError) {
        Fluttertoast.showToast(msg: 'Error, could not add favorite');
      });
    }

    //at the end it sets loading to false and updateStar to true to let know that the favorite state was updated
    //this is crucial for the functionality of the exam page
    controller.isLoading = false;
    //
    controller.updateStar = true;
    controller.notifyNoob();

    return null;
  }
}

/* Dialog in charge of adding and editing terms of the glossary*/
class DialogAddNewTerm extends StatefulWidget {
  final TermModel term;
  final bool emptyTerm;
  //var used to check if the term is changed on edit and helps validate if it is a dupe or not
  final String? termBackUp;

  const DialogAddNewTerm(
      {Key? key, required this.term, required this.emptyTerm, this.termBackUp})
      : super(key: key);

  @override
  State<DialogAddNewTerm> createState() => _DialogAddNewTermState();
}

class _DialogAddNewTermState extends State<DialogAddNewTerm> {
  //recieves the dropdownvalue which is the current term type, and then is used in the dropdown of types
  late String dropdownValue = widget.term.type;
  //recieves the value tag of the current term,  and then is used in the dropdown of tags
  late String dropdownValueTags = widget.term.tag;

  //text editing controller for the text field
  TextEditingController textEditingControllerTerm = TextEditingController();
  //text editing controller of the answer field
  TextEditingController textEditingControllerAnswer = TextEditingController();
  //stores the term name while editing the term text input and helps to compare if the term is already added before or no
  late String termName = widget.term.term;
  //stores the answer value of the input text on formsave
  late String termAnswer;
  //the final term type in string variable
  late String termType;
  /*checks if the widget was called with an empty term or a existing term.  being called by an empty term means
  that the add function is required and being called with an existing term, means that the edit features are required*/
  late bool emptyTerm = widget.emptyTerm;

  //variable that checks if the widget is in the middle of some process and displays loading features if it happens to be true
  bool isLoading = false;
  //handles the favorite state of the term while editing or adding a new term
  bool favorite = false;
  //tag value of the term
  String tag = 'untagged';
  //glossary model to use the current glossary model later
  GlossaryModel? glossaryModel;

  @override
  Widget build(BuildContext context) {
    //equals the texediting controllers to its respective values so when the context
    //is refreshed they manage to keep them
    textEditingControllerTerm.text = termName;
    textEditingControllerAnswer.text = widget.term.answer;

    //form key for the form used in the dialog
    final formKey = GlobalKey<FormState>();
    Controller controller = Provider.of<Controller>(context);
    glossaryModel = controller.currentGlossary;

    final textThemeTilte = Theme.of(context).textTheme.headline5;

    return WillPopScope(
      onWillPop: () async {
        //doesn't allow to pop the scope if a process is loading :)
        return isLoading ? false : true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            /*checks if there is a user currently in exam, if there happens to be one then it displays a message to the user 
            instead of the intented form in order to deny the edit and add features to the user while someone else is in exam
            this is with the porpouse of not messing up the data of the glossary*/
            child: controller.currentGlossary.usersInExamList.isEmpty
                ? Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emptyTerm ? 'Add a new term' : 'Edit term',
                          style: textThemeTilte,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                maxLength: 50,
                                onChanged: (value) {
                                  //this is here so the value doesnt reset on context refresh
                                  termName = value;
                                },
                                enabled: !isLoading,
                                controller: textEditingControllerTerm,
                                //a button that adds the current value of the text edtitng controller to the clipboard
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                                text: textEditingControllerTerm
                                                    .text))
                                            .then((_) {
                                          Fluttertoast.showToast(
                                              msg: 'Term copied',
                                              toastLength: Toast.LENGTH_LONG);
                                        });
                                      },
                                      icon: const Icon(Icons.copy)),
                                  labelText: 'Term',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                //the validator checks that the value is not empty
                                validator: (value) {
                                  if (value!.trim() == '') {
                                    return 'Please give a name to the term';
                                  }
                                  return null;
                                },
                                //on saved saves its value to the termName variable
                                onSaved: (value) {
                                  termName = value!.capitalize();
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //text for field for the answer variable
                              TextFormField(
                                maxLength: 150,
                                //on changed it equals its value to the term.answer value
                                onChanged: (value) {
                                  widget.term.answer = value;
                                },
                                enabled: !isLoading,
                                controller: textEditingControllerAnswer,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                        ClipboardData? data =
                                            await Clipboard.getData(
                                                'text/plain');
                                        setState(() {
                                          widget.term.answer = data?.text ?? '';
                                        });
                                      },
                                      icon: const Icon(Icons.paste)),
                                  labelText: 'Answer',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                //checks that the input is not empty
                                validator: (value) {
                                  if (value!.trim() == '') {
                                    return 'Please give a meaning or translation';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  termAnswer = value!;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //dropdown button that allows the user to select the value of the termtype
                              dropDownButtonTermType(),
                              //dropdown button that allows the user to select the value of the term tag
                              dropDownButtonTermTag(controller),
                              //if it is loading shows a circular progress indicadtor instead of the button bar to stop user inputs
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : ButtonBar(
                                      children: [
                                        //cancel button
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        //if it is an empty term it show the favorite status button
                                        //if it isn it just show a container
                                        emptyTerm
                                            ? IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    favorite =
                                                        favorite ? false : true;
                                                  });
                                                },
                                                icon: Icon(
                                                  favorite
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: favorite
                                                      ? Colors.amber
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                ))
                                            : Container(),
                                        //button add term edit term
                                        ElevatedButton(
                                          onPressed: () async {
                                            await addEditTerm(
                                                controller, formKey);
                                          },
                                          child: emptyTerm
                                              ? const Text('Add term')
                                              : const Text('Edit term'),
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    'Someone is in exam, wait for his/her exam to finish in order to edit or add terms'),
          ),
        ),
      ),
    );
  }

  //adds or edits a term depending on the current term and configuration
  Future addEditTerm(
      Controller controller, GlobalKey<FormState> formKey) async {
    //validates that the inputs in the text fields are right, if they are not it returns
    if (!formKey.currentState!.validate()) {
      return;
    }
    //puts the form in the save state to get the values
    formKey.currentState!.save();
    //reloads the context with loading on true to display progress indicator
    setState(() {
      isLoading = true;
    });
    if (!emptyTerm) {
      await editTerm(controller);
    } else {
      await addTerm(controller);
    }

    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  //adds a new term to the list
  Future addTerm(Controller controller) async {
    /*first checks that the list is not empty, if the list happens to be empty then it just goes to the 
    next step and proceeds to add the term, if it is not empty then it checks that the list does not contain the term already
    to not have dupes */
    if (controller.unfilteredTermList.isNotEmpty) {
      if (controller.unfilteredTermList
          .where((element) =>
              element.term.trim().toLowerCase().capitalize() ==
              textEditingControllerTerm.text.trim().toLowerCase().capitalize())
          .isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'This term already exists', toastLength: Toast.LENGTH_LONG);
        isLoading = false;
        setState(() {});
        return;
      }
    }

    //updates the currentglossary lol, easy
    await controller.currentGlossary.documentReference
        .update({
          'termsList': FieldValue.arrayUnion([
            {
              'term': termName.capitalize(),
              'answer': termAnswer.capitalize(),
              'type': dropdownValue,
              'tag': dropdownValueTags,
              'favoritesList': favorite ? ['user'] : []
            }
          ])
        })
        .then((value) => Fluttertoast.showToast(msg: 'Added a new term'))
        .catchError((onError) =>
            Fluttertoast.showToast(msg: 'Error, could not add term'));
  }

  Future editTerm(Controller controller) async {
    /*verifies that the termbackup variable, which contains the first value of the term,
    is not equal to the termNAme variable if it is then it has to check with another if, if the 
    unfilteredtermlist does not contain the term already, if the term is already there then it displays a message letting the
    user know that the term is already added and therefore it can not be duplicated */
    bool hasError = false;
    if (widget.termBackUp!.trim().toLowerCase().capitalize() !=
        termName.trim().toLowerCase().capitalize()) {
      if (controller.unfilteredTermList.where((element) {
        return element.term.trim().toLowerCase().capitalize() ==
            termName.trim().toLowerCase().capitalize();
      }).isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'This term already exists', toastLength: Toast.LENGTH_LONG);
        isLoading = false;
        setState(() {});
        return;
      }
    }

    /*if it is found that the term is same with the termback it just procceeds with everything and if 
    it is not same but it is not in the list then it goes to this part*/

    //equals the term variables to the current settings selected
    widget.term.term = textEditingControllerTerm.text.capitalize();
    widget.term.answer = textEditingControllerAnswer.text.capitalize();
    widget.term.type = dropdownValue;
    widget.term.tag = dropdownValueTags;

    //based on the term index it equals the same index on the currentglosarry term list to the term
    controller.currentGlossary.termsMapList[widget.term.listIndex] =
        widget.term.toMap();

    //reference of the current glossary
    final DocumentReference glossaryDocRef =
        controller.currentGlossary.documentReference;

    //bool that checks that the term was not modified seconds before the transaction
    bool glossaryModifiedWhileEdit = false;

    //runs a transaction of the current glossary to get its latest info and do a proper update
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot glossarySnapshot = await transaction.get(glossaryDocRef);

      //checks that the glossary still exists, if it does it equals a glossary model to the current glossary snapshot
      if (glossarySnapshot.exists) {
        GlossaryModel glossary =
            GlossaryModel.fromDocumentSnapshot(glossarySnapshot);
        //checks that the term to be edited is still there, if it isn't this means that the glossary has been modified and
        //therefor updating the list like this could cause problems, so the process needs to be canceled
        if (glossary.termsMapList
            .where((element) => element['term'] == widget.termBackUp)
            .isEmpty) {
          glossaryModifiedWhileEdit = true;
          return;
        }
        //checks if the index to be edited is still the same
        if (glossary.termsMapList[widget.term.listIndex]['term'] !=
            widget.termBackUp) {
          glossaryModifiedWhileEdit = true;
          return;
        }
        transaction.update(glossaryDocRef, controller.currentGlossary.toMap());
        controller.mapListToTermsList();
        controller.notifyNoob();
        //erros displayeed when something bad occurs
      } else {
        hasError = true;
        Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg:
                'Error, updating, retstart the app and check your internet connection');
      }
    }).onError((error, stackTrace) {
      hasError = true;
      Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg:
              'Error, updating, retstart the app and check your internet connection');
    }).then((value) {
      if (hasError) {
        return;
      }
      Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: glossaryModifiedWhileEdit
              ? 'The current glossary got modified while you were editing, try again'
              : 'Updated succesfully');
    });
  }

  //dropdown button that displays the list of tags avaliable for the terms

  Padding dropDownButtonTermTag(Controller controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<dynamic>(
        value: dropdownValueTags,
        style: TextStyle(color: dropDownTextColor()),
        icon: const Icon(Icons.arrow_downward),
        underline: Container(
          height: 2,
          color: primary,
        ),
        onChanged: (dynamic newValue) {
          setState(() {
            if (isLoading) {
              return;
            }
            dropdownValueTags = newValue!.toString();
          });
        },
        //the items a re build with the currentglossary list of tags they are converted into a map
        //and then returnet as a dropdownmenuitem, this is complicated code
        items: controller.currentGlossary.tags
            .map<DropdownMenuItem<dynamic>>((dynamic value) {
          return DropdownMenuItem<dynamic>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  //dropdown button that displays the list of types avaliable for the terms

  Padding dropDownButtonTermType() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: dropdownValue,
        style: TextStyle(color: dropDownTextColor()),
        icon: const Icon(Icons.arrow_downward),
        underline: Container(
          height: 2,
          color: primary,
        ),
        onChanged: (String? newValue) {
          if (isLoading) {
            return;
          }
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: enumTypeToList().map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  //gives the color to the dropdown text
  Color dropDownTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  //sets the type enum to a list so it can be used in the dropdown button
  List<String> enumTypeToList() {
    List<String> list = [];
    Type.values.toList().forEach((element) {
      list.add(element.toString());
    });
    return list;
  }
}
