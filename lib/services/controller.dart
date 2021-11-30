import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/colors.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:elephant/themes/app_main_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:elephant/themes/app_main_theme.dart';

enum ExamType { useTerms, useAnswers, mixed }

class Controller with ChangeNotifier {
  UserModel user = UserModel(username: 'Kno');
  late GlossaryModel _currentGlossary;
  late TermModel currentTerm;

  int currentTermCount = 0;

  //mutlipleOption tiles && exams variables
  bool updateStar = true;
  bool tileStatus = true;
  Color tileColor = primary;

  int currentCardIndex = 1;

  //bool
  bool useFilteredTerms = false;
  bool mixTermsAnswers = false;
  bool testFromAnswers = false;
  bool testFromTerms = true;
  bool difficultExam = false;

  bool useFavoriteTerms = false;

  bool isLoading = false;

  bool useFixedLength = false;

  //used to detect if the user is in the search page
  bool isSearching = false;

  bool userDataInitialized = false;
  bool navigateToHomeExecuted = false;

  ExamType examType = ExamType.useTerms;

  //lists

  late List<TermModel> currentTermList = [];
  late List<TermModel> wrongTerms = [];
  late List<TermModel> rightTerms = [];
  late List<dynamic> selectedTags = [];
  late List<QueryDocumentSnapshot> currentGlossaryDocuments;
  late List<TermModel> difficultTermList = [];

  late List<QueryDocumentSnapshot> currentFilteredGlossaryDocuments = [];

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

  List<TermModel> generateCurrentTermsList({required int examLength}) {
    //makes a new term list with the current glossary documents obtained from the stream
    currentTermList.clear();
    if (examLength == 0 || examLength >= currentGlossaryDocuments.length) {
      for (var element in currentGlossaryDocuments) {
        currentTermList.add(TermModel.fromDocumentSnapshot(element));
      }

      currentTermList.shuffle();
      return currentTermList;
    }

    for (int i = 0; i < examLength; i++) {
      currentTermList
          .add(TermModel.fromDocumentSnapshot(currentGlossaryDocuments[i]));
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

  resetControllerVars() {
    wrongTerms.clear();
    rightTerms.clear();
    currentTermList.clear();
    currentTermCount = 0;
  }

  //Creates a query to show for the glossary page, the main porpouse of this is to have a way to filter the terms on a glossary
  Stream<QuerySnapshot> queryStreamCreator() {
    Stream<QuerySnapshot> stream;
    if (selectedTags.isEmpty) {
      if (useFavoriteTerms) {
        stream = currentGlossary.documentReference
            .collection('terms')
            .where('favoritesList', arrayContains: 'user')
            .orderBy('term', descending: true)
            .snapshots()
            .handleError((onError) {
          print(onError);
        });
      } else {
        stream = currentGlossary.documentReference
            .collection('terms')
            .orderBy('term', descending: true)
            .snapshots();
      }
    } else {
      if (useFavoriteTerms) {
        stream = currentGlossary.documentReference
            .collection('terms')
            .where('tag', whereIn: selectedTags)
            .where('favoritesList', arrayContains: 'user')
            .orderBy('term', descending: true)
            .snapshots()
            .handleError((onError) {
          //handle error
        });
      } else {
        stream = currentGlossary.documentReference
            .collection('terms')
            .where('tag', whereIn: selectedTags)
            .orderBy('term', descending: true)
            .snapshots()
            .handleError((onError) {
          //handle error
        });
      }
    }

    return stream;
  }

  String termTypeToString(TermModel termModel) {
    return termModel.type.replaceRange(0, 5, '').capitalize();
  }

  set currentGlossary(GlossaryModel currentGlossary) {
    _currentGlossary = currentGlossary;
  }

  loginCheck() {}

  initilizedUserData() async {
    await assignTheme();
    userDataInitialized = true;
    notifyListeners();
  }

//
//
//
//
  //theme stuff

  late String currentThemeKeyWord;

  assignTheme() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    currentThemeKeyWord = prefs.getString('currentTheme') ?? 'Greelephant';
    ColorScheme lightColorScheme;
    ColorScheme darkColorScheme;
    switch (currentThemeKeyWord) {
      case 'Yellowphant':
        lightColorScheme = GalleryThemeData.lightColorSchemeYellow;
        darkColorScheme = GalleryThemeData.darkColorSchemeYellow;
        break;
      case 'Bluelephant':
        lightColorScheme = GalleryThemeData.lightColorSchemeBlue;
        darkColorScheme = GalleryThemeData.darkColorSchemeBlue;
        break;
      case 'Greelephant':
        lightColorScheme = GalleryThemeData.lightColorSchemeGudGreen;
        darkColorScheme = GalleryThemeData.darkColorSchemeGudGreen;
        break;
      case 'Orangephant':
        lightColorScheme = GalleryThemeData.lightColorSchemeOrange;
        darkColorScheme = GalleryThemeData.darkColorSchemeOrange;
        break;
      default:
        lightColorScheme = GalleryThemeData.lightColorSchemeGudGreen;
        darkColorScheme = GalleryThemeData.darkColorSchemeGudGreen;
        break;
    }
    light = GalleryThemeData.themeData(
        lightColorScheme, GalleryThemeData.lightFocusColor);

    dark = GalleryThemeData.themeData(
        darkColorScheme, GalleryThemeData.lightFocusColor);
  }

  onSelectTheme(ColorScheme colorSchemeLight, ColorScheme colorSchemeDark,
      String value) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    light = GalleryThemeData.themeData(
        colorSchemeLight, GalleryThemeData.lightFocusColor);
    dark = GalleryThemeData.themeData(
        colorSchemeDark, GalleryThemeData.darkFocusColor);
    await prefs.setString('currentTheme', value);
    notifyListeners();
  }

  ThemeData light = GalleryThemeData.themeData(
      GalleryThemeData.lightColorSchemeGudGreen,
      GalleryThemeData.lightFocusColor);

  ThemeData dark = GalleryThemeData.themeData(
      GalleryThemeData.darkColorSchemeGudGreen,
      GalleryThemeData.lightFocusColor);
}
