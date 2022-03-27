import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:elephant/themes/app_main_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum ExamType { useTerms, useAnswers, mixed }

class Controller with ChangeNotifier {
  //user model?
  UserModel user = UserModel(username: 'Kno');
  late UserModel activeUser;
  //current glossary is used to handle the glossary that is currently being displayed in the
  //glossary page and it helps a lot to eddit, add or delete stuff from it
  late GlossaryModel _currentGlossary;

  //this is not used lol
  late TermModel currentTerm;
  //not used anymore
  int currentTermCount = 0;

  //mutlipleOption tiles && exams variables
  //
  //
  //updateStar is used for when you want to update the favorite status of a term
  //inside an exam this helps a lot it is fundamental on not having the options list being made once again
  //on context state refresh
  bool updateStar = true;
  //Tile status is also fundamental too, specially cause this lets the exam navigate propperly and
  //also it is fundamental on rebuilding the state of the multiple option exam
  bool tileStatus = true;
  //this was supposed to be used for other stuff but idk lol, now handles the icon color
  Color tileColor = primary;

  //eh? not used anymore lol
  int currentCardIndex = 1;
  //ints for counting how many of a certain type are there
  int totalAdjectives = 0;
  int totalNouns = 0;
  int totalVerbs = 0;
  int totalAdverbs = 0;
  int totalPhrases = 0;

  //exam preparation variables
  //fixed examlength is used for handling the value recieved during the exam settings page config
  int fixedExamLength = 0;
  //real fixed examlength is used on the exam page to double check if the value in examlength is
  //adequate to be used depending on the currentnumber of terms in the list and to check that it is not 0
  //and also used on the examresult page to get the total of the terms tested
  int realFixedExamLength = 0;

  //bool
  //this is not used anymore
  bool useFilteredTerms = false;
  //not used anymore lol
  bool mixTermsAnswers = false;
  //not used anymore lol
  bool testFromAnswers = false;
  //not used anymore?
  bool testFromTerms = true;
  //checks if the exam to present its from the difficult terms or the normal terms
  bool difficultExam = false;

  //allows the buildfiltered term list to know if the favorite terms are the only ones
  //to be used or no
  bool useFavoriteTerms = false;

  //this loading var is super super important and is used in many parts of code
  //it handles everything related to let the user know when the app is loading to
  //display progress indicators or to restric/allow the user certain interactions
  bool isLoading = false;

  //enables and disables the fixed length feature in the exam settings page
  bool useFixedLength = false;

  bool orderAlphabetically = false;

  //used to detect if the user is in the search page
  bool isSearching = false;

  //vars used in the app start page
  //this checks if the userData has already been initialized in order to not do it twice
  bool userDataInitialized = false;
  //checks if the navigation to home has already been executed so it is not executed again
  bool navigateToHomeExecuted = false;

  //this bool is used to check if the first connection tick has ocurred or not
  bool firstConnectionTick = false;

  //this bool is for the status connection of the app, checks if there is a wifi connection or not
  bool internetConnection = true;

  //fundamental to know the examtype for the multiple option exam
  ExamType examType = ExamType.useTerms;

  //lists
  //fundamental list that is returned when the user has selected filtering options for the terms
  late List<TermModel> filteredTermList = [];
  //pure unfiltered list of the terms straight form the db
  late List<TermModel> unfilteredTermList = [];
  //used in the exam to display the terms and assigned in the exam settings page based on the settings
  late List<TermModel> currentTermList = [];
  //list used to store the wrong answers during the exam
  late List<TermModel> wrongTerms = [];
  //list used to store the right answers during the exam
  late List<TermModel> rightTerms = [];
  //list used to store the selected tags by the user when filtering the term list
  late List<dynamic> selectedTags = [];
  //not used anymore
  late List<QueryDocumentSnapshot> currentGlossaryDocuments;
  //used instead of the currenttermlist when the exam is a difficult exam
  late List<TermModel> difficultTermList = [];

  //not used anymore
  late List<QueryDocumentSnapshot> currentFilteredGlossaryDocuments = [];

  //streams
  //not used anymore
  late Stream<QuerySnapshot> queryStream;

  //pagecontrolles
  //page controller in charge of the exam navigation
  PageController pageControllerExam = PageController(
    initialPage: 0,
  );

  //functions

  //function that checks if the uid is registerted in the db
  Future<bool> login(User user, BuildContext context) async {
    var userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    if (userDocs.docs.isEmpty) {
      print('new user needs to be registered');
      Navigator.of(context).pushNamed('/registerPage');
    } else {
      activeUser = UserModel.newUserLogin(user, userDocs.docs.first);
      print('logging in');
      Navigator.of(context).pop();
    }
    return true;
  }

  //function that checks if the ag is inside the select tags already to display its value
  bool checkTagSelected(String tag) {
    bool selected;
    if (selectedTags.contains(tag)) {
      selected = true;
    } else {
      selected = false;
    }

    return selected;
  }

  //checks if it is the lastpage of the exam, so instead of navigating it goes to the exam results
  bool checkIfLastPage() {
    bool lastPage = false;
    if (pageControllerExam.page == currentTermList.length - 1) {
      lastPage = true;
    }
    return lastPage;
  }

  // ignore: unnecessary_getters_setters
  GlossaryModel get currentGlossary => _currentGlossary;

  //assigns icons depending on the type of the term
  //not used anymore
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

  //???? lol i should delete this
  shortenTermList() {}

  //assignts the the right list to the list to be displayed takes in count the orderalphabetically bool
  //and the selected tags and favoriteterms bool
  List<TermModel> listAssignerFunction() {
    mapListToTermsList();
    if (orderAlphabetically) {
      unfilteredTermList.sort((a, b) => (a.term).compareTo(b.term));
    }
    if (selectedTags.isNotEmpty || useFavoriteTerms) {
      buildFilteredTermList();
      return filteredTermList;
    }

    return unfilteredTermList;
  }

  //builds the filtered term list depending on the settings chosen by the user

  buildFilteredTermList() {
    filteredTermList.clear();

    for (var term in unfilteredTermList) {
      if (useFavoriteTerms && selectedTags.isNotEmpty) {
        if (selectedTags.contains(term.tag) &&
            term.favoritesList.contains('user')) {
          filteredTermList.add(term);
        }
      } else if (useFavoriteTerms && selectedTags.isEmpty) {
        if (term.favoritesList.contains('user')) {
          filteredTermList.add(term);
        }
      } else if (!useFavoriteTerms && selectedTags.isNotEmpty) {
        if (selectedTags.contains(term.tag)) {
          filteredTermList.add(term);
        }
      }
    }
  }

  //
  //connectivity checking code
  //
  //
  //

  //
  //
  //this functions is very important and good cause it is in charge of making the terms from the maps obtained from the database

  mapListToTermsList() {
    unfilteredTermList.clear();
    int i = 0;
    totalAdjectives = 0;
    totalAdverbs = 0;
    totalNouns = 0;
    totalVerbs = 0;
    totalPhrases = 0;
    for (var map in currentGlossary.termsMapList) {
      TermModel toAddTerm = TermModel.fromMap(map, i);
      unfilteredTermList.add(toAddTerm);
      i++;
      switch (toAddTerm.typeEnum) {
        case Type.verb:
          totalVerbs++;
          break;
        case Type.adverd:
          totalAdverbs++;
          break;
        case Type.noun:
          totalNouns++;
          break;
        case Type.phrase:
          totalPhrases++;
          break;
        case Type.adjective:
          totalAdjectives++;
          break;
      }
    }
  }

  // List<TermModel> generateCurrentTermsList({required int examLength}) {
  //   //makes a new term list with the current glossary documents obtained from the stream
  //   currentTermList.clear();
  //   if (examLength == 0 || examLength >= currentGlossary.termsMapList.length) {
  //     for (var element in currentGlossary.termsMapList) {
  //       currentTermList.add(TermModel.fromDocumentSnapshot(element));
  //     }

  //     currentTermList.shuffle();
  //     return currentTermList;
  //   }

  //   for (int i = 0; i < examLength; i++) {
  //     currentTermList
  //         .add(TermModel.fromMap(currentGlossary.termsMapList[i], i));
  //   }

  //   currentTermList.shuffle();
  //   return currentTermList;
  // }

  //Function use the notify listeners func out of the controller lol
  notifyNoob() {
    notifyListeners();
  }

  //generates the difficult term list based the current unfilteredTermList
  generateDifficultTermList() {
    difficultTermList.clear();
    for (var element in unfilteredTermList) {
      if (element.difficultTerm) {
        difficultTermList.add(element);
      }
    }
  }

  //resets some of the variables of the controller so they can be used again and don't interfere in the future
  resetControllerVars() {
    wrongTerms.clear();
    rightTerms.clear();
    currentTermList.clear();
    currentTermCount = 0;
  }

  Future<bool> hasNetwork() async {
    bool connected = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        connected = true;
      }
    } on SocketException catch (_) {
      print('not connected');
      connected = false;
    }
    return connected;
  }

  //Creates a query to show for the glossary page, the main porpouse of this is to have a way to filter the terms on a glossary
  //this code is not used anymore as the terms are now maps instead of docs, but ill leave it here cause its very cool
  Stream<QuerySnapshot> queryStreamCreator() {
    Stream<QuerySnapshot> stream;
    if (selectedTags.isEmpty) {
      if (useFavoriteTerms) {
        stream = currentGlossary.documentReference
            .collection('terms')
            .where('favoritesList', arrayContains: 'user')
            .orderBy('term', descending: true)
            .snapshots()
            .handleError((onError) {});
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

  //gets the termtype and puts is a string, it also removes the first 5 characters which are type.
  String termTypeToString(TermModel termModel) {
    return termModel.type.replaceRange(0, 5, '').capitalize();
  }

  set currentGlossary(GlossaryModel currentGlossary) {
    _currentGlossary = currentGlossary;
  }

  //function to be used later that checks if there is an active session
  loginCheck() {}

  //function in charge of intializing the user data, it still needs to be re programmed later
  initilizedUserData() async {
    await assignTheme();
    userDataInitialized = true;
    notifyListeners();
  }

  List<TermModel> termTypeListCreator(Type termType) {
    List<TermModel> termTypeList = [];
    termTypeList = unfilteredTermList
        .where((element) => element.typeEnum == termType)
        .toList();
    return termTypeList;
  }

  //this function is in charge of running a transaction on the current glossary, and it also recieves a function it can perform some actions
  //before the glossary is updated and it updates its data
  Future<bool> currentGlossaryTransaction(Function toChange) async {
    bool status = true;
    //gets the glossary doc ref
    final DocumentReference glossaryDocRef = currentGlossary.documentReference;
    //starts the transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      //gets the snapshots
      DocumentSnapshot glossarySnapshot = await transaction.get(glossaryDocRef);
      //if the snapshot exists in then proceeds to convert the obtained snapshot to a glossarymodel to get the lates current info
      if (glossarySnapshot.exists) {
        currentGlossary = GlossaryModel.fromDocumentSnapshot(glossarySnapshot);
        //after that it just executes the desired changes
        toChange();
        //and then submits the changes to the db
        transaction.update(glossaryDocRef, currentGlossary.toMap());
        //displays erros if there happens to be any
      } else {
        status = false;
        Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg:
                'Error, updating, retstart the app and check your internet connection');
      }
    }).onError((error, stackTrace) {
      status = false;
      Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg:
              'Error, updating, retstart the app and check your internet connection');
    }).then((value) {
      Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG, msg: 'Updated succesfully');
    });

    return status;
  }

//
//
//
//
//theme stuff

  late String currentThemeKeyWord;

  //gets the current theme selected by the user and initilizes it from the app start page
  //uses the sharedpref package so the data persists even after closing the app
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

  //this function is used in the theme_chooser_page and once a theme is selected it stores the current config
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

  //themedata of the light and dark themes
  ThemeData light = GalleryThemeData.themeData(
      GalleryThemeData.lightColorSchemeGudGreen,
      GalleryThemeData.lightFocusColor);

  ThemeData dark = GalleryThemeData.themeData(
      GalleryThemeData.darkColorSchemeGudGreen,
      GalleryThemeData.lightFocusColor);
}
