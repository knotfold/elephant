import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:provider/provider.dart';

//widget in charge of testing stuff, should not be avaliable on the publish version
class WidgetTester extends StatefulWidget {
  const WidgetTester({Key? key}) : super(key: key);

  @override
  State<WidgetTester> createState() => _WidgetTesterState();
}

class _WidgetTesterState extends State<WidgetTester> {
  late StreamSubscription _connectionChangeStream;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
      // body: FutureBuilder(
      //   future: changeTermsDocsToList(controller),
      //   builder: (context, asyncSnapshot) {
      //     if (!asyncSnapshot.hasData) {
      //       return SingleChildScrollView(
      //         child: Padding(
      //           padding: const EdgeInsets.all(20),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.max,
      //             children: const [
      //               Text('Loading results'),
      //               CircularProgressIndicator(),
      //             ],
      //           ),
      //         ),
      //       );
      //     }

      //     if (asyncSnapshot.data == false) {
      //       return const ErrorConnection();
      //     }

      //     return Container();
      //   },
      // ),
    );
  }
}

Future<bool> changeTermsDocsToList(Controller controller) async {
  bool result = true;
  QuerySnapshot query = await controller.currentGlossary.documentReference
      .collection('terms')
      .get();
  // print(query.docs.length);
  List<DocumentSnapshot> docs = query.docs;
  List<Map<String, dynamic>> termList = [];
  for (var doc in docs) {
    termList.add(TermModel.fromDocumentSnapshot(doc).toMap());
  }
  // await controller.currentGlossary.documentReference.update({
  //   'termsList': FieldValue.arrayUnion([
  //     {
  //       'answer': 'To work hard',
  //       'difficultTerm': true,
  //       'favoritesList': ['user'],
  //       'tag': 'Unit 9',
  //       'term': '힘쓰다',
  //       'type': 'Type.verb'
  //     }
  //   ])
  // }).then((value) {
  //   result = true;
  // }).onError((error, stackTrace) {
  //   result = false;
  // }).timeout(Duration(seconds: 60), onTimeout: () {
  //   result = false;
  // });

//
////
//
  //
  // print('here');
  // await controller.currentGlossary.documentReference
  //     .update({'termsList': termList}).then((value) {
  //   result = true;
  // }).onError((error, stackTrace) {
  //   result = false;
  // }).timeout(Duration(seconds: 60), onTimeout: () {
  //   result = false;
  // });
  return result;
}
