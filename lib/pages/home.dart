import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:elephant/pages/pages.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:elephant/services/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

//the home page is in charge of displaying all the glossaries ina grid view
class _HomeState extends State<Home> {
  final Stream<QuerySnapshot> _glossaryStream =
      FirebaseFirestore.instance.collection('glossaries').snapshots();

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    //stream of all the glossaries

    return StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
          print(snapshot.data);
          if (snapshot.data != ConnectivityResult.wifi &&
              snapshot.data != ConnectivityResult.mobile) {
            if (!controller.firstConnectionTick) {
              controller.firstConnectionTick = true;
            } else {
              controller.internetConnection = false;

              // Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }
          } else {
            controller.internetConnection = true;
          }

          return Scaffold(
            //floating action button that shows a dialog to add a new glossary
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                dialogNewGlossary(context);
              },
              child: const Icon(Icons.add),
            ),
            appBar: myAppBar(context: context, type: 'home'),
            body: HomeBodyWidget(glossaryStream: _glossaryStream),
          );
        });
  }

  Future<dynamic> dialogNewGlossary(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return const DialogAddNewGlossary();
        });
  }
}

//body of the homepage
class HomeBodyWidget extends StatelessWidget {
  const HomeBodyWidget({
    Key? key,
    required Stream<QuerySnapshot<Object?>> glossaryStream,
  })  : _glossaryStream = glossaryStream,
        super(key: key);

  //Stream of glossaries lol
  final Stream<QuerySnapshot<Object?>> _glossaryStream;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    return Container(
      padding: const EdgeInsets.all(5),
      //streambuilder that monitors all the glossaries
      child: StreamBuilder<QuerySnapshot>(
        stream: _glossaryStream,
        builder: (context, snapshot) {
          //if the snapshot has an error it displays an error widget

          if (snapshot.hasError) {
            print(snapshot.error);
            return const ErrorConnection();
          }

          //if it doesn't have data means that is loading
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.connectionState.name == ' waiting') {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          //list of the snapshot docs
          List<QueryDocumentSnapshot> queryDocuments = snapshot.data!.docs;
          //if the documents list is empty, means there is not glossaries added
          if (queryDocuments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'You don not have glossaries in your library, try adding a new one clicking the + button below',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          //if the list is not empty then it show a grid view of the current glossaries
          return GridView.builder(
              itemCount: queryDocuments.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) {
                return GlossaryCard(
                    glossary: GlossaryModel.fromDocumentSnapshot(
                  queryDocuments[index],
                ));
              });
        },
      ),
    );
  }
}

class DialogAddNewGlossary extends StatefulWidget {
  const DialogAddNewGlossary({Key? key}) : super(key: key);

  @override
  State<DialogAddNewGlossary> createState() => _DialogAddNewGlossaryState();
}

//dialog to add new glossary
class _DialogAddNewGlossaryState extends State<DialogAddNewGlossary> {
  //bool in charge of displaying if something is loading
  bool isLoading = false;
  //reference of the glossaries collection
  CollectionReference glossaries =
      FirebaseFirestore.instance.collection('glossaries');
  //variable that will store the new glossary name
  late String newGlossaryName;

  //form key that controls the form state
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final textThemeTitle = Theme.of(context).textTheme.headline5;

    Controller controller = Provider.of<Controller>(context);
    return WillPopScope(
      //doesn't allow to pop the scope if it is loading
      onWillPop: () async {
        return isLoading ? false : true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Add a new glossary',
                      style: textThemeTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    maxLength: 30,
                    decoration: const InputDecoration(
                      labelText: 'Glossary name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    validator: (value) {
                      //validates that the inputfield is not empty
                      if (value!.trim() == '') {
                        return 'Please give a name to the glossary';
                      }
                    },
                    onSaved: (value) {
                      newGlossaryName = value!;
                    },
                  ),
                  //if it is loading it hides the buttons with a progress indicator to avoid more usir inputs
                  isLoading
                      ? const CircularProgressIndicator()
                      : ButtonBar(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                formKey.currentState!.save();
                                setState(() {
                                  isLoading = true;
                                });
                                await glossaries
                                    .add({
                                      'name': newGlossaryName,
                                      'user': controller.user.username,
                                      'tags': ['untagged']
                                    })
                                    .catchError((onError) {
                                      isLoading = false;
                                      setState(() {});
                                      Navigator.of(context).pop();
                                      Fluttertoast.showToast(
                                          msg:
                                              'Error adding the glossary, check your connection',
                                          toastLength: Toast.LENGTH_LONG);
                                    })
                                    // ignore: avoid_print
                                    .then((value) => print('User Added'))
                                    .timeout(
                                      const Duration(seconds: 30),
                                      onTimeout: () {
                                        isLoading = false;
                                        setState(() {});
                                        Navigator.of(context).pop();
                                        Fluttertoast.showToast(
                                            msg:
                                                'Error adding the glossary, check your internet connection',
                                            toastLength: Toast.LENGTH_LONG);
                                      },
                                    );
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Add glossary'),
                            ),
                          ],
                        )
                ],
              )),
        ),
      ),
    );
  }
}
