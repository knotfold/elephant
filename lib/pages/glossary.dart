import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/pages/exam.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/shared.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Type { verb, adverd, noun, phrase }

// ignore: must_be_immutable
class GlossaryPage extends StatelessWidget {
  const GlossaryPage({
    Key? key,
  }) : super(key: key);

  navigateToDifficultTerms(BuildContext context, Controller controller) {
    controller.generateCurrentTermsList();
    controller.generateDifficultTermList();
    Navigator.of(context).pushNamed('/difficultTermsPage');
  }

  @override
  Widget build(BuildContext context) {
    final textStyleHeadline = Theme.of(context).textTheme.headline5;
    Controller controller = Provider.of<Controller>(context);
    final Stream<QuerySnapshot> _termStream = controller
        .currentGlossary.documentReference
        .collection('terms')
        .orderBy('term', descending: true)
        .snapshots();

    return WillPopScope(
      onWillPop: () async {
        controller.selectedTags.clear();
        controller.useFavoriteTerms = false;
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  heroTag: 'difficultTerms',
                  onPressed: () {
                    navigateToDifficultTerms(context, controller);
                  },
                  child: const Icon(Icons.healing_rounded),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                  heroTag: 'addNewTerms',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DialogAddNewTerm(
                        glossaryModel: controller.currentGlossary,
                        term: TermModel(
                            '', '', Type.values.first.toString(), 'untagged'),
                        emptyTerm: true,
                      ),
                    );
                  },
                  label: const Text('New term'),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ),
            ],
          ),
        ),
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
                Text(
                  'Terms',
                  style: textStyleHeadline,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: controller.queryStreamCreator(),
                  builder: (context, snapshot) {
                    //TODO: display error
                    if (snapshot.hasError) {
                      return Container();
                    }
                    //TODO: display error
                    if (!snapshot.hasData) {
                      return Container(
                        child: const CircularProgressIndicator(),
                      );
                    }

                    controller.currentGlossaryDocuments = snapshot.data!.docs;

                    if (controller.currentGlossaryDocuments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'This glossary does not contain any terms, would you like to add some to it? Click the add button down below',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

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

    return ListView.builder(
      physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
      shrinkWrap: true,
      itemCount: controller.currentGlossaryDocuments.length,
      itemBuilder: (context, index) {
        TermModel term = TermModel.fromDocumentSnapshot(
            controller.currentGlossaryDocuments[index]);
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
                            glossaryModel: controller.currentGlossary,
                            term: term,
                            emptyTerm: false,
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
              IconButton(
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
                        Fluttertoast.showToast(
                            msg: 'Error, could not add term');
                      });
                    } else {
                      await term.reference.update({
                        'favoritesList': FieldValue.arrayUnion(['user'])
                      }).then((value) {
                        term.isFavorite = true;
                        Fluttertoast.showToast(msg: 'Added to favorites');
                      }).catchError((onError) {
                        Fluttertoast.showToast(
                            msg: 'Error, could not add term');
                      });
                    }

                    controller.isLoading = false;

                    //Add to favs
                  },
                  icon: Icon(
                    term.isFavorite ? Icons.star : Icons.star_border,
                    color: term.isFavorite
                        ? Colors.amber
                        : Theme.of(context).colorScheme.onBackground,
                  ))
            ],
          ),
          leading: Icon(controller.termIconAsignner(term.type)),
          title: Text(term.term),
          subtitle: Text(term.answer),
        );
      },
    );
  }
}

class DialogStartButton extends StatefulWidget {
  const DialogStartButton({Key? key}) : super(key: key);

  @override
  State<DialogStartButton> createState() => _DialogStartButtonState();
}

class _DialogStartButtonState extends State<DialogStartButton> {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleTheme = Theme.of(context).textTheme.headline6;
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select an option',
            style: textStyleTheme,
          ),
          const SizedBox(height: 30),
          controller.selectedTags.isEmpty
              ? Container()
              : const Text(
                  'Exam and flash cards will start with the currently applied filters, click the button to clear the tags and use all the terms'),
          controller.selectedTags.isEmpty
              ? Container()
              : ElevatedButton(
                  onPressed: () {
                    controller.selectedTags.clear();
                    controller.useFavoriteTerms = false;
                    controller.notifyNoob();
                    setState(() {});
                  },
                  child: const Text('Clear filters')),
          const SizedBox(
            height: 25,
          ),

          //old switch selector
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       'No',
          //       style: TextStyle(
          //           color: controller.useFilteredTerms ? pLight : Colors.black),
          //     ),
          //     Switch(
          //         value: controller.useFilteredTerms,
          //         onChanged: (onChanged) {
          //           controller.useFilteredTerms = onChanged;
          //           setState(() {});
          //         }),
          //     Text(
          //       'Yes',
          //       style: TextStyle(
          //           color: controller.useFilteredTerms ? Colors.black : pLight),
          //     ),
          //   ],
          // ),

          const Text('Select the question and answer configuration'),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   mainAxisSize: MainAxisSize.min,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          RadioListTile<ExamType>(
            title: const Text('Use Terms'),
            value: ExamType.useTerms,
            groupValue: controller.examType,
            onChanged: (ExamType? value) {
              setState(() {
                controller.examType = value!;
              });
            },
          ),

          RadioListTile<ExamType>(
            title: const Text('Use Answers'),
            value: ExamType.useAnswers,
            groupValue: controller.examType,
            onChanged: (ExamType? value) {
              setState(() {
                controller.examType = value!;
              });
            },
          ),

          RadioListTile<ExamType>(
            title: const Text('Mixed'),
            value: ExamType.mixed,
            groupValue: controller.examType,
            onChanged: (ExamType? value) {
              setState(() {
                controller.examType = value!;
              });
            },
          ),
          //   ],
          // ),

          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.currentGlossaryDocuments.isEmpty) {
                Fluttertoast.showToast(
                    msg:
                        'There is not terms in the current glossary or with the applied filters');
                return;
              }
              navigateToExam(
                'exam',
                context,
                controller,
              );
            },
            child: const Text('Open Question Exam'),
          ),

          controller.currentGlossaryDocuments.length < 4
              ? Container()
              : ElevatedButton(
                  onPressed: () {
                    if (controller.currentGlossaryDocuments.isEmpty) {
                      Fluttertoast.showToast(
                          msg:
                              'There is not terms in the current glossary or with the applied filters');
                      return;
                    }
                    navigateToExam(
                      'multipleOption',
                      context,
                      controller,
                    );
                  },
                  child: const Text('Multiple Option Exam'),
                ),

          ElevatedButton(
              onPressed: () {
                if (controller.currentGlossaryDocuments.isEmpty) {
                  Fluttertoast.showToast(
                      msg:
                          'There is not terms in the current glossary or with the applied filters');
                  return;
                }
                navigateToExam(
                  'flashCards',
                  context,
                  controller,
                );
              },
              child: const Text('Flash Cards'))
        ],
      ),
    ));
  }
}

navigateToExam(
  String type,
  BuildContext context,
  Controller controller,
) {
  Navigator.of(context).pop();
  controller.clearLists();
  controller.generateCurrentTermsList();

  Navigator.of(context).pushNamed(ExamPage.routeName,
      arguments: ExamArguments(
        examType: type,
      ));
}

class DialogAddNewTerm extends StatefulWidget {
  final GlossaryModel glossaryModel;
  final TermModel term;
  final bool emptyTerm;
  const DialogAddNewTerm(
      {Key? key,
      required this.glossaryModel,
      required this.term,
      required this.emptyTerm})
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

  String tag = 'untagged';

  @override
  Widget build(BuildContext context) {
    textEditingControllerTerm.text = widget.term.term;
    textEditingControllerAnswer.text = widget.term.answer;

    bool isLoading = false;

    final formKey = GlobalKey<FormState>();
    Controller controller = Provider.of<Controller>(context);
    CollectionReference termsCollectionRef =
        widget.glossaryModel.documentReference.collection('terms');

    final textThemeTilte = Theme.of(context).textTheme.headline4;

    return Dialog(
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
                  'Add a new term',
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
                        onChanged: (value) {
                          widget.term.term = value;
                        },
                        controller: textEditingControllerTerm,
                        decoration: const InputDecoration(
                          labelText: 'Term',
                          border: OutlineInputBorder(
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
                          termName = value!;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
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
                              .map<DropdownMenuItem<dynamic>>((dynamic value) {
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
