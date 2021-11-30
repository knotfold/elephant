import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/colors.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/pages/pages.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: query)).then((_) {
            Fluttertoast.showToast(
                msg: 'Term copied', toastLength: Toast.LENGTH_LONG);
          });
        },
        icon: const Icon(Icons.copy),
      ),
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.cancel_outlined))
    ];
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
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        indicatorColor: Theme.of(context).colorScheme.secondary,
        colorScheme: Theme.of(context).colorScheme,
        primaryColor: primary,
        primaryIconTheme: theme.iconTheme,
        highlightColor: Theme.of(context).colorScheme.secondary,
        textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Theme.of(context).colorScheme.secondary,
            selectionColor: Theme.of(context).colorScheme.secondary,
            cursorColor: Theme.of(context).colorScheme.secondary),
        inputDecorationTheme: InputDecorationTheme(
            fillColor: Theme.of(context).colorScheme.secondary,
            hoverColor: Theme.of(context).colorScheme.secondary,
            focusColor: Theme.of(context).colorScheme.secondary,
            helperStyle:
                TextStyle(color: Theme.of(context).colorScheme.secondary)),
        textTheme: theme.textTheme.copyWith());
  }

  @override
  Widget? buildLeading(BuildContext context) {
    Controller controller = Provider.of(context);
    // TODO: implement buildLeading
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
      ),
      onPressed: () {
        controller.isSearching = false;
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
    if (query.isEmpty || query.trim() == '') {
      return Container();
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        StreamBuilder<QuerySnapshot>(
            stream: _termStream,
            builder: (context, snapshot) {
              if (query.isEmpty || query.trim() == '') {
                return Container();
              }
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

              controller.currentFilteredGlossaryDocuments = snapshot.data!.docs;

              // print('there is docs');

              if (controller.currentFilteredGlossaryDocuments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(25.0),
                          child: Text(
                            'There is not terms matching the search query, click the button below to add the current search as a new term',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            controller.isSearching = false;
                            Navigator.of(context).pop();
                            Clipboard.setData(ClipboardData(text: query))
                                .then((_) {
                              Fluttertoast.showToast(
                                  msg: 'Term copied',
                                  toastLength: Toast.LENGTH_LONG);
                            });

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogAddNewTerm(
                                      term: TermModel(
                                          query,
                                          '',
                                          Type.values.first.toString(),
                                          'untagged'),
                                      emptyTerm: true);
                                });
                          },
                          icon: const Icon(Icons.add_circle_outline))
                    ],
                  ),
                );
              }

              controller.isSearching = true;

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
