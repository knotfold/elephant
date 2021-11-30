import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/shared.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';

// ignore: must_be_immutable
class GlossaryPage extends StatefulWidget {
  const GlossaryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);
  @override
  void initState() {
    _bottomBarController.itemsStream.listen((index) {
      Future.delayed(Duration.zero, () {
        switch (index) {
          case 0:
            navigateToDifficultTerms(context);
            break;
          case 1:
            Navigator.of(context).pushNamed('/examSettingsPage');

            break;
          case 2:
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(),
            );
            break;
          case 3:
            Navigator.of(context).pushNamed('/filterGlossaryTermsPage');
            break;
          case 4:
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

  navigateToDifficultTerms(BuildContext context) {
    Controller controller = Provider.of<Controller>(context, listen: false);
    controller.generateDifficultTermList();
    Navigator.of(context).pushNamed('/difficultTermsPage');
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Controller controller = Provider.of<Controller>(context);
    final Stream<QuerySnapshot> _termStream = controller
        .currentGlossary.documentReference
        .collection('terms')
        .orderBy('term', descending: true)
        .snapshots();

    return WillPopScope(
      onWillPop: () async {
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
          bottomBarTheme: BottomBarTheme(
            itemIconColor: Theme.of(context).colorScheme.onBackground,
            selectedItemIconColor: Theme.of(context).colorScheme.onBackground,
            mainButtonPosition: MainButtonPosition.right,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ),
          sheetChild: Container(
            child: Text(
              'Are you sure you want to delete me?',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
          controller: _bottomBarController,
          items: const [
            BottomBarWithSheetItem(icon: Icons.healing_rounded),
            BottomBarWithSheetItem(icon: Icons.play_circle_outline_outlined),
            BottomBarWithSheetItem(icon: Icons.search),
            BottomBarWithSheetItem(icon: Icons.filter_list),
            BottomBarWithSheetItem(icon: Icons.add_circle_outline),
          ],
        ),

        //old floating actoin buttons that got replaced for the bottombarwithsheet
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(15.0),
        //   child: Stack(
        //     fit: StackFit.loose,
        //     children: <Widget>[
        //       Align(
        //         alignment: Alignment.bottomLeft,
        //         child: FloatingActionButton(
        //           heroTag: 'difficultTerms',
        //           onPressed: () {
        //             navigateToDifficultTerms(context, controller);
        //           },
        //           child: const Icon(Icons.healing_rounded),
        //         ),
        //       ),
        //       Align(
        //         alignment: Alignment.bottomRight,
        //         child: FloatingActionButton.extended(
        //           heroTag: 'addNewTerms',
        //           onPressed: () {
        //             showDialog(
        //               context: context,
        //               builder: (context) => DialogAddNewTerm(
        //                 glossaryModel: controller.currentGlossary,
        //                 term: TermModel(
        //                     '', '', Type.values.first.toString(), 'untagged'),
        //                 emptyTerm: true,
        //               ),
        //             );
        //           },
        //           label: const Text('New term'),
        //           icon: const Icon(Icons.add_circle_outline),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        appBar: myAppBar(
            title: controller.currentGlossary.name,
            context: context,
            type: 'glossary'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: controller.queryStreamCreator(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const ErrorConnection();
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(25.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    controller.currentGlossaryDocuments = snapshot.data!.docs;

                    if (controller.currentGlossaryDocuments.isEmpty) {
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

                    controller.currentTermCount =
                        controller.currentGlossaryDocuments.length;

                    return ListViewBuilderTerms(controller: controller);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        controller.isSearching
            ? Container()
            : Text(
                'Terms ${controller.currentTermCount}',
                style: textStyleHeadline,
              ),
        SizedBox(
          height: double.maxFinite * 0.90,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  TermModel term = TermModel.fromDocumentSnapshot(
                      controller.currentGlossaryDocuments[index]);
                  return Slidable(
                    direction: Axis.horizontal,
                    actionPane: const SlidableScrollActionPane(),
                    actions: [
                      IconSlideAction(
                        color: Colors.red,
                        caption: 'Delete',
                        icon: Icons.delete_forever,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Are you sure you want to delete this term?'),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () async {
                                        controller.isLoading = true;
                                        await controller
                                            .currentGlossaryDocuments[index]
                                            .reference
                                            .delete()
                                            .onError((error, stackTrace) {});
                                        Navigator.of(context).pop();
                                        controller.isLoading = false;
                                      },
                                      child: const Text('Delete'))
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                    child: ListTileTerm(term: term, controller: controller),
                  );
                }, childCount: controller.currentGlossaryDocuments.length),
              ),
            ],
          ),
        ),
        // ListView.builder(
        //   physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
        //   itemCount: controller.currentGlossaryDocuments.length,
        //   itemBuilder: (context, index) {
        //     TermModel term = TermModel.fromDocumentSnapshot(
        //         controller.currentGlossaryDocuments[index]);
        //     return Slidable(
        //       direction: Axis.horizontal,
        //       actionPane: const SlidableScrollActionPane(),
        //       actions: [
        //         IconSlideAction(
        //           color: Colors.red,
        //           caption: 'Delete',
        //           icon: Icons.delete_forever,
        //           onTap: () {
        //             showDialog(
        //               context: context,
        //               builder: (context) {
        //                 return AlertDialog(
        //                   title: const Text(
        //                       'Are you sure you want to delete this term?'),
        //                   actions: [
        //                     ElevatedButton(
        //                         onPressed: () {
        //                           Navigator.of(context).pop();
        //                         },
        //                         child: const Text('Cancel')),
        //                     ElevatedButton(
        //                         onPressed: () async {
        //                           controller.isLoading = true;
        //                           await controller
        //                               .currentGlossaryDocuments[index].reference
        //                               .delete()
        //                               .onError((error, stackTrace) {});
        //                           Navigator.of(context).pop();
        //                           controller.isLoading = false;
        //                         },
        //                         child: const Text('Delete'))
        //                   ],
        //                 );
        //               },
        //             );
        //           },
        //         ),
        //       ],
        //       child: ListTileTerm(term: term, controller: controller),
        //     );
        //   },
        // ),
      ],
    );
  }
}

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
          if (controller.isLoading) {
            return;
          }
          controller.isLoading = true;
          if (term.isFavorite) {
            await term.reference.update({
              'favoritesList': FieldValue.arrayRemove(['user'])
            }).then((value) {
              term.isFavorite = false;
              Fluttertoast.showToast(msg: 'Removed from favorites');
            }).catchError((onError) {
              Fluttertoast.showToast(msg: 'Error, could not remove favorite');
            });
          } else {
            await term.reference.update({
              'favoritesList': FieldValue.arrayUnion(['user'])
            }).then((value) {
              term.isFavorite = true;
              Fluttertoast.showToast(msg: 'Added to favorites');
            }).catchError((onError) {
              Fluttertoast.showToast(msg: 'Error, could not favorite');
            });
          }

          controller.isLoading = false;
          //
          controller.updateStar = true;
          controller.notifyNoob();

          //Add to favs
        },
        icon: Icon(
          term.isFavorite ? Icons.star : Icons.star_border,
          color: term.isFavorite
              ? Colors.amber
              : Theme.of(context).colorScheme.onBackground,
        ));
  }
}

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
  late String dropdownValue = widget.term.type;
  late String dropdownValueTags = widget.term.tag;
  TextEditingController textEditingControllerTerm = TextEditingController();
  TextEditingController textEditingControllerAnswer = TextEditingController();
  late String termName;
  late String termAnswer;
  late String termType;
  late bool emptyTerm = widget.emptyTerm;

  bool isLoading = false;

  bool favorite = false;

  String tag = 'untagged';

  GlossaryModel? glossaryModel;

  @override
  Widget build(BuildContext context) {
    textEditingControllerTerm.text = widget.term.term;
    textEditingControllerAnswer.text = widget.term.answer;

    final formKey = GlobalKey<FormState>();
    Controller controller = Provider.of<Controller>(context);
    glossaryModel = controller.currentGlossary;
    CollectionReference termsCollectionRef =
        glossaryModel!.documentReference.collection('terms');

    final textThemeTilte = Theme.of(context).textTheme.headline5;

    return WillPopScope(
      onWillPop: () async {
        return isLoading ? false : true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
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
                            widget.term.term = value;
                          },
                          controller: textEditingControllerTerm,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                          text: textEditingControllerTerm.text))
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
                          validator: (value) {
                            if (value!.trim() == '') {
                              return 'Please give a name to the term';
                            }
                          },
                          onSaved: (value) {
                            termName = value!.capitalize();
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          maxLength: 150,
                          onChanged: (value) {
                            widget.term.answer = value;
                          },
                          controller: textEditingControllerAnswer,
                          decoration: const InputDecoration(
                            labelText: 'Answer',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.trim() == '') {
                              return 'Please give a meaning or translation';
                            }
                          },
                          onSaved: (value) {
                            termAnswer = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
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
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: enumToList()
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        Padding(
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
                                dropdownValueTags = newValue!.toString();
                              });
                            },
                            items: controller.currentGlossary.tags
                                .map<DropdownMenuItem<dynamic>>(
                                    (dynamic value) {
                              return DropdownMenuItem<dynamic>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        isLoading
                            // ignore: dead_code
                            ? const CircularProgressIndicator()
                            : ButtonBar(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
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
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      formKey.currentState!.save();
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (!emptyTerm) {
                                        if (widget.termBackUp!
                                                .trim()
                                                .capitalize() !=
                                            textEditingControllerTerm.text
                                                .trim()
                                                .capitalize()) {
                                          if (!await checkDupeTerm(
                                              termsCollectionRef, termName)) {
                                            Fluttertoast.showToast(
                                                msg: 'This term already exists',
                                                toastLength: Toast.LENGTH_LONG);
                                            isLoading = false;
                                            setState(() {});
                                            return;
                                          }
                                        }

                                        widget.term.term =
                                            textEditingControllerTerm.text
                                                .capitalize();
                                        widget.term.answer =
                                            textEditingControllerAnswer.text
                                                .capitalize();
                                        widget.term.type = dropdownValue;
                                        widget.term.tag = dropdownValueTags;

                                        await widget.term.reference
                                            .update(widget.term.toMap());
                                      } else {
                                        if (!await checkDupeTerm(
                                            termsCollectionRef, termName)) {
                                          Fluttertoast.showToast(
                                              msg: 'This term already exists',
                                              toastLength: Toast.LENGTH_LONG);

                                          return;
                                        }

                                        await addNewTerm(termsCollectionRef);
                                      }

                                      setState(() {
                                        isLoading = false;
                                      });
                                      Navigator.of(context).pop();
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
            ),
          ),
        ),
      ),
    );
  }

  String captilize(String string) {
    string.replaceRange(1, 1, string.characters.first.toUpperCase());

    return "${string[0].toUpperCase()}${string.substring(1)}";
  }

  Color dropDownTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Future addNewTerm(CollectionReference termsCollectionRef) async {
    await termsCollectionRef
        .add({
          'term': termName.capitalize(),
          'answer': termAnswer.capitalize(),
          'type': dropdownValue,
          'tag': dropdownValueTags,
          'favoritesList': favorite
              ? FieldValue.arrayUnion(['user'])
              : FieldValue.arrayUnion([])
        })
        .then((value) => Fluttertoast.showToast(msg: 'Added a new term'))
        .catchError((onError) =>
            Fluttertoast.showToast(msg: 'Error, could not add term'));
  }

  Future<bool> checkDupeTerm(
      CollectionReference termsCollectionRef, String term) async {
    bool status = true;

    QuerySnapshot querySnapshot = await termsCollectionRef
        .where('term', isEqualTo: term)
        .get()
        .catchError((onError) {
      status = false;
      print(onError.toString());
    });
    if (querySnapshot.docs.isNotEmpty) {
      status = false;
    }

    return status;
  }

  List<String> enumToList() {
    List<String> list = [];
    Type.values.toList().forEach((element) {
      list.add(element.toString());
    });
    return list;
  }
}
