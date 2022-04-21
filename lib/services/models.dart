import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elephant/shared/shared.dart';

//enum of the types that a term can have, this help us to classify them
enum Type { verb, adverd, noun, phrase, adjective }

//model for the user of the app, this still needs more work
class UserModel {
  late String username;
  late String email;
  late String usernamePlain;
  late String uid;
  late dynamic creationDate;
  late dynamic lastLoginTime;
  late UserCredential userCredential;

  UserModel({required this.username});

  UserModel.userNotRegistered(User user) {
    username = '';
    email = user.email ?? '';
    uid = user.uid;
    creationDate = user.metadata.creationTime;
    lastLoginTime = user.metadata.lastSignInTime;
  }

  UserModel.userRegistered(User user, DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    username = data['username'] ?? '';
    email = user.email ?? '';
    uid = user.uid;
    usernamePlain = username.toLowerCase();
    creationDate = user.metadata.creationTime;
    lastLoginTime = user.metadata.lastSignInTime;
  }

  UserModel.fromDS() {}

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'uid': uid,
      'creationDate': creationDate,
      'lastLoginTime': lastLoginTime,
      'usernamePlain': usernamePlain
    };
  }
}

//glossary model is for the models of the glossaries lol
class GlossaryModel {
  //name of the glossary
  late String name;
  //name of the glossary but everything in lower case to find it easily
  late String nameSearch;
  //creation date of the glossary
  late Timestamp creationDate;
  //last time a user has checked the glossary, might need to change this to a list of maps
  late Timestamp lastChecked;
  //tags that the current glossary has to filter the terms
  late List<dynamic> tags;
  //main tag that defines the concept of the glossary
  late String mainCategory;
  //the enum of the mainTag
  late MainCategory mainCategoryEnum;
  //terms inside the glossary, they are maps :)
  late List<dynamic> termsMapList;
  /*this list is in charge of monitoring users that are in a exam and helps us to know when an user is in a exam so 
  the glossary does not get modified while someone is at it*/
  late List<dynamic> usersInExamList;
  //reference to the database of the glosary
  late DocumentReference documentReference;
  //creator user
  late String creator;
  //list of participating users
  late List<dynamic> glossaryUsers;
  //rating recieved
  late List<dynamic> userRatings;
  //rating average
  double rating = 0;
  //origin is a variable used to track the family from where the glossary comes from
  late String origin;
  //tracks the amount of times a glossary has been cloned
  late int dCounter;
  //stores de document id of the glossary
  late String id;
  //svaes the father documentreference
  late DocumentReference fatherDocRef;

  //this function is very importarnt because it takes a documentsnapshot and converts it into a glossary model.
  GlossaryModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    name = data['name'];
    creationDate = data['creationDate'] ?? Timestamp.fromDate(DateTime.now());
    lastChecked = Timestamp.fromDate(DateTime.now());
    tags = data['tags'] ?? [];
    termsMapList = data['termsList'] ?? [];
    usersInExamList = data['usersInExamList'] ?? [];
    documentReference = documentSnapshot.reference;
    creator = data['creator'] ?? '';
    glossaryUsers = data['glossaryUsers'] ?? [];
    Map<String, dynamic> userRatingsReplacementMap = {
      'user': 'user',
      'rating': 0
    };
    userRatings = data['userRatings'] ?? [userRatingsReplacementMap];
    for (var element in userRatings) {
      rating = rating + element['rating'];
    }
    rating = userRatings.isEmpty ? 0 : (rating / userRatings.length);
    mainCategory = data['mainCategory'] ?? 'MainCategory.other';
    mainCategoryEnum = MainCategory.values
        .firstWhere((element) => element.toString() == mainCategory);
    origin = data['origin'] ?? '';
    dCounter = data['dCounter'] ?? 0;
    id = documentSnapshot.id;
  }

  //gets the glossarymodel and turns it into a map, this is specially useful for addting or updating stuff to the db
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameSearch': name.toLowerCase().trim(),
      'creationDate': creationDate,
      'tags': tags,
      'lastChecked': lastChecked,
      'usersInExamList': usersInExamList,
      'termsList': termsMapList,
      'creator': creator,
      'glossaryUsers': glossaryUsers,
      'userRatings': userRatings,
      'rating': rating,
      'mainCategory': mainCategory,
      'origin': origin,
      'dCounter': dCounter,
    };
  }
}

//termModel for the terms on the app
class TermModel {
  //this is the term term or name
  late String term;
  //the term answer it's just the matching value
  late String answer;
  //the type is a classification of the term, although is not used for filtering as of right now, would be used later for different stuff
  late String type;
  //the tag input is the current tag that the term belongs to, this might be changed to a list later so the term can have multiple tags
  late String tag;
  //the type enum is not stored in the database but it helps for functionality on the app
  late Type typeEnum;
  //this value is not used anymore
  late DocumentReference reference;
  //checks if the term is a difficult term for the user based on the userlistdifficulterms list of the term
  late bool difficultTerm;
  //checks if the user has the term as a favorite based on the favoriteslist
  late bool isFavorite;
  //stores the users that have favorited the term on a list
  late List<dynamic> favoritesList;
  //stores the users that find the term difficult on a list
  late List<dynamic> usersListDifficultTerms;
  //this index is super important because it helps identify the temr better in the list of maps that the glossary has
  late int listIndex;

  //based constructor mostly used in the add term to add a new empty term
  TermModel(this.term, this.answer, this.type, this.tag);

  //makes a termmodel from a map, it recieves the map and the index it has on the glossary list
  TermModel.fromMap(Map<String, dynamic> map, int index) {
    term = map['term'] ?? 'Error';
    answer = map['answer'] ?? 'Error';
    type = map['type'] ?? 'Error';
    tag = map['tag'] ?? 'untagged';
    typeEnum = Type.values.firstWhere((element) => element.toString() == type);
    listIndex = index;
    favoritesList = map['favoritesList'] ?? [];
    isFavorite = checkIfFavorite(favoritesList, 'user');
    usersListDifficultTerms = map['usersListDifficultTerms'] ?? [];
    difficultTerm = usersListDifficultTerms.contains('user');
  }

  //makes a termmodel from a ds, this is not used anymore because the terms are not stored as docs anymore
  TermModel.fromDocumentSnapshot(DocumentSnapshot ds) {
    Map<String, dynamic> data = ds.data()! as Map<String, dynamic>;
    term = data['term'] ?? 'Error';
    answer = data['answer'] ?? 'Error';
    type = data['type'] ?? 'Error';
    tag = data['tag'] ?? 'untagged';
    typeEnum = Type.values.firstWhere((element) => element.toString() == type);
    reference = ds.reference;
    difficultTerm = data['difficultTerm'] ?? false;
    favoritesList = data['favoritesList'] ?? [];
    isFavorite = checkIfFavorite(favoritesList, 'user');
    usersListDifficultTerms = [];
  }

  //checks is the favorite list constains the user as its favorite and returns true of false lol
  bool checkIfFavorite(List<dynamic> list, String user) {
    return list.contains('user');
  }

  //gets the current termmodel and turns it into a map, helful for updating or adding terms
  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'answer': answer,
      'type': type,
      'tag': tag,
      'difficultTerm': difficultTerm,
      'favoritesList': favoritesList,
      'usersListDifficultTerms': usersListDifficultTerms
    };
  }
}
