import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:flutter/material.dart';
import 'package:elephant/pages/pages.dart';
import 'package:provider/provider.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  // @override
  // String get searchFieldLabel => 'Example: Hello';

  // Future<List<DocumentSnapshot>> buildSearchList(
  //     List<DocumentSnapshot> documents) async {
  //   List<DocumentSnapshot> filteredDocuments = [];
  //   documents.forEach((document) {
  //     if (document['usuarioSearch'].contains(query.toLowerCase())) {
  //       filteredDocuments.add(document);
  //     }
  //   });
  //   return filteredDocuments;
  // }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Controller controller = Provider.of(context);

    final Stream<QuerySnapshot> _termStream =
        controller.currentGlossary.documentReference
            .collection('terms')
            .where('term', isEqualTo: query.capitalize())
            // .orderBy('term', descending: true)
            .snapshots();
    if (query.isEmpty || query.trim() == '') {}

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        StreamBuilder<QuerySnapshot>(
            stream: _termStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                  child: Text('Error'),
                );
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

              print('there is docs');

              if (controller.currentGlossaryDocuments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(25.0),
                          child: Text(
                            'There is not terms matching the search query',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListViewBuilderTerms(controller: controller);
            }),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}
