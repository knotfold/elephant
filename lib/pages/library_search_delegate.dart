import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/colors.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/pages/pages.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

/*this class in search on displaying a searchpage using the custom search delegate that flutter offers
and searchs through the unfiltered term list to find a term by matching the written input with the term term
if there happens to be none then lets the user know and offers the users a quick shortcut to add the new term*/
class LibrarySearchDelegate extends SearchDelegate {
  @override
  /*the actions are displayed on the appbar, and for this widget we have a button to copy the
  current user input to the clipboard and another one to clear the query */
  List<Widget>? buildActions(BuildContext context) {
    return [
      //copies input to clipboard
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
        onPressed: () {},
        icon: Icon(Icons.filter_list),
      ),
      //erases the query
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.cancel_outlined),
      ),
    ];
  }

  /*the theme of the appbar is in charge of making the this page match with our style, this is necessary
  because the custom search delegator for some weird reason, does not follow the settings of the apptheme*/
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

  //leading is the button that appears before the query input field and we used to pop the context
  @override
  Widget? buildLeading(BuildContext context) {
    Controller controller = Provider.of(context);
    //navigates back to the glossary page
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

  //builds the widget to be displayed in the body of the search page
  @override
  Widget buildResults(BuildContext context) {
    Controller controller = Provider.of(context);
    double deviceHeigth = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('glossaries')
          .where('nameSearch',
              isGreaterThanOrEqualTo: query.toLowerCase().trim())
          .where('nameSearch',
              isLessThanOrEqualTo: query.toLowerCase().trim() + '~')
          .snapshots(),
      builder: (context, snapshot) {
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
        List<QueryDocumentSnapshot> queryDocuments = snapshot.data!.docs;
        print(queryDocuments.length);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Results'),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: queryDocuments.length,
                  itemBuilder: (context, index) {
                    GlossaryModel glossaryModel =
                        GlossaryModel.fromDocumentSnapshot(
                      queryDocuments[index],
                    );
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlossaryCard(
                          glossary: glossaryModel,
                          route: '/glossaryInfoPage',
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.text_format_rounded),
                                Text('Terms: ' +
                                    glossaryModel.termsMapList.length
                                        .toString()),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.date_range),
                                Text('Creation date: ' +
                                    controller.timeStampToNormalDate(
                                        glossaryModel.creationDate
                                            .toDate()
                                            .toString())),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(controller.mainCategoryIconChooser(
                                    glossaryModel.mainCategoryEnum)),
                                Text(controller.mainCategoryToString(
                                    glossaryModel.mainCategory)),
                              ],
                            ),
                          ],
                        )
                      ],
                    );
                  }),
            ],
          ),
        );
      },
    );
//if nothing is written then we display nothing
    if (query.isEmpty || query.trim() == '') {
      return Column(
        children: [
          const Text('Glossary library'),
          ListView.builder(itemBuilder: (index, context) {
            // return GlossaryCard(glossary: glossary);
          })
        ],
      );
    }
//once something is written on the input field we start applying logic to the code
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        //with a future builder we use the filterControllerList to find the terms that contain the written input
        FutureBuilder<List<TermModel>>(
          future: filterControllerList(controller),
          builder: (context, snapshot) {
            //checks that the query is not empty once again
            if (query.isEmpty || query.trim() == '') {
              return Container();
            }
            //displays an error on connection problems
            if (snapshot.hasError) {
              return const ErrorConnection();
            }

            //if the snapshot doesnt have daya means that the function is still loading
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            //once the snapshot has data it recieves it as a list of terms
            List<TermModel> searchedTermList = snapshot.data!;

            /*if the list is empty then it displays a message letting the user know that the current glossary does not contain that 
            term and shows the user a button with a shortcut to add the term */
            if (searchedTermList.isEmpty) {
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
                    //button with a shortcut to add the term based on the current query
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

            //if the list is not empty then it displays it as a listview

            controller.isSearching = true;

            return SizedBox(
              height: deviceHeigth * 0.80,
              child: SingleChildScrollView(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: searchedTermList.length,
                  itemBuilder: (context, index) {
                    return ListTileTerm(
                        term: searchedTermList[index], controller: controller);
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  //function in charge of finding which terms contain or match the current query
  Future<List<TermModel>> filterControllerList(Controller controller) async {
    List<TermModel> filteredList = [];
    for (var term in controller.unfilteredTermList) {
      if (term.term.toLowerCase().contains(query.trim().toLowerCase())) {
        filteredList.add(term);
      }
    }
    return filteredList;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}
