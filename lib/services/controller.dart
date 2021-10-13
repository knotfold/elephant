import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ExamType { useTerms, useAnswers, mixed }

class Controller with ChangeNotifier {
  UserModel user = UserModel(username: 'Kno');
  late GlossaryModel _currentGlossary;
  late TermModel currentTerm;

  //bool
  bool useFilteredTerms = false;
  bool mixTermsAnswers = false;
  bool testFromAnswers = false;
  bool testFromTerms = true;
  bool difficultExam = false;

  ExamType examType = ExamType.useTerms;

  //lists

  late List<TermModel> currentTermList = [];
  late List<TermModel> wrongTerms = [];
  late List<TermModel> rightTerms = [];
  late List<dynamic> selectedTags = [];
  late List<QueryDocumentSnapshot> currentGlossaryDocuments;
  late List<TermModel> difficultTermList = [];

  //streams
  late Stream<QuerySnapshot> queryStream;

  //pagecontrolles
  PageController pageControllerExam = PageController(
    initialPage: 0,
  );

  //functions
  bool checkTagSelected(String tag) {
    bool selected;
    if (selectedTags.contains(tag)) {
      selected = true;
    } else {
      selected = false;
    }

    return selected;
  }

  bool checkIfLastPage() {
    bool lastPage = false;
    if (pageControllerExam.page == currentTermList.length - 1) {
      lastPage = true;
    }
    return lastPage;
  }

  // ignore: unnecessary_getters_setters
  GlossaryModel get currentGlossary => _currentGlossary;

  IconData termIconAsignner(String type) {
    IconData iconData;
    switch (type) {
      case 'Type.adverb':
        iconData = Icons.center_focus_strong_outlined;
        break;
      case 'Type.verb':
        iconData = Icons.run_circle_outlined;
        break;
      case 'Type.noun':
        iconData = Icons.person;
        break;
      case 'Type.phrase':
        iconData = Icons.format_quote;
        break;
      default:
        iconData = Icons.downhill_skiing_rounded;
        break;
    }
    return iconData;
  }

  List<TermModel> generateCurrentTermsList() {
    //makes a new term list with the current glossary documents obtained from the stream
    currentTermList.clear();

    for (var element in currentGlossaryDocuments) {
      currentTermList.add(TermModel.fromDocumentSnapshot(element));
    }

    currentTermList.shuffle();
    return currentTermList;
  }

  notifyNoob() {
    notifyListeners();
  }

  generateDifficultTermList() {
    difficultTermList.clear();
    for (var element in currentTermList) {
      if (element.difficultTerm) {
        difficultTermList.add(element);
      }
    }
  }

  clearLists() {
    wrongTerms.clear();
    rightTerms.clear();
    currentTermList.clear();
  }

  //Creates a query to show for the glossary page, the main porpouse of this is to have a way to filter the terms on a glossary
  Stream<QuerySnapshot> queryStreamCreator() {
    Stream<QuerySnapshot> stream;
    if (selectedTags.isEmpty) {
      stream = currentGlossary.documentReference
          .collection('terms')
          .orderBy('term', descending: true)
          .snapshots();
    } else {
      stream = currentGlossary.documentReference
          .collection('terms')
          .where('tag', whereIn: selectedTags)
          .orderBy('term', descending: true)
          .snapshots()
          .handleError((onError) {
        print(onError);
      });
      // switch (selectedTags.length) {
      //   case 1:

      //     break;
      //   default:
      //     stream = currentGlossary.documentReference
      //         .collection('terms')
      //         .orderBy('term', descending: true)
      //         .snapshots();
      //     break;
      // }
    }

    return stream;
  }

  set currentGlossary(GlossaryModel currentGlossary) {
    _currentGlossary = currentGlossary;
  }
}
