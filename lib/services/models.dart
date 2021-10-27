import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Type { verb, adverd, noun, phrase, adjective }

class User {
  late String username;
  late dynamic creationDate;
}

class GlossaryModel {
  late String name;

  late Timestamp creationDate;
  late Timestamp lastChecked;
  late List<dynamic> tags;

  late DocumentReference documentReference;

  GlossaryModel.fromDocumentSnapshot(QueryDocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    name = data['name'];
    creationDate = data['creationDate'] ?? Timestamp.fromDate(DateTime.now());
    lastChecked = data['lastChecked'] ?? Timestamp.fromDate(DateTime.now());
    tags = data['tags'] ?? [];
    documentReference = documentSnapshot.reference;
  }
}

class TermModel {
  late String term;
  late String answer;
  late String type;
  late String tag;
  late Type typeEnum;
  late DocumentReference reference;
  late bool difficultTerm;
  late bool isFavorite;
  late List<dynamic> favoritesList;

  TermModel(this.term, this.answer, this.type, this.tag);

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
  }

  bool checkIfFavorite(List<dynamic> list, String user) {
    return list.contains('user');
  }

  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'answer': answer,
      'type': type,
      'tag': tag,
      'difficultTerm': difficultTerm,
    };
  }
}

class UserModel {
  late String username;

  UserModel({required this.username});
}
