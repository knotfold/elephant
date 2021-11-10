import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/shared.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _glossaryStream =
        FirebaseFirestore.instance.collection('glossaries').snapshots();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dialogNewGlossary(context);
        },
        child: const Icon(Icons.add),
      ),
      appBar: myAppBar(context: context, type: 'home'),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: StreamBuilder<QuerySnapshot>(
          stream: _glossaryStream,
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
            List<QueryDocumentSnapshot> queryDocuments = snapshot.data!.docs;
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
      ),
    );
  }

  Future<dynamic> dialogNewGlossary(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return const DialogAddNewGlossary();
        });
  }
}

class DialogAddNewGlossary extends StatefulWidget {
  const DialogAddNewGlossary({Key? key}) : super(key: key);

  @override
  State<DialogAddNewGlossary> createState() => _DialogAddNewGlossaryState();
}

class _DialogAddNewGlossaryState extends State<DialogAddNewGlossary> {
  bool isLoading = false;
  CollectionReference glossaries =
      FirebaseFirestore.instance.collection('glossaries');
  late String newGlossaryName;

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final textThemeTitle = Theme.of(context).textTheme.headline5;

    Controller controller = Provider.of<Controller>(context);
    return WillPopScope(
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
                      if (value!.trim() == '') {
                        return 'Please give a name to the glossary';
                      }
                    },
                    onSaved: (value) {
                      newGlossaryName = value!;
                    },
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
                                    .then((value) => print('User Added'))
                                    .catchError(
                                        (onError) => print('error ocurred'));
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
