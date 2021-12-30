
/*
dead code contains a lot of unused code that could be used in the future
but mostly it helps as a history of code changes.
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
//old dialog class used to start the exam and choose its settings, it got replaced by the current exam_settings_page
//
// class DialogStartButton extends StatefulWidget {
//   const DialogStartButton({Key? key}) : super(key: key);

//   @override
//   State<DialogStartButton> createState() => _DialogStartButtonState();
// }

// class _DialogStartButtonState extends State<DialogStartButton> {
//   @override
//   Widget build(BuildContext context) {
//     Controller controller = Provider.of<Controller>(context);
//     final textStyleTheme = Theme.of(context).textTheme.headline6;
//     return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Select an option',
//                 style: textStyleTheme,
//               ),
//               const SizedBox(height: 30),
//               controller.selectedTags.isEmpty
//                   ? Container()
//                   : const Text(
//                       'Exam and flash cards will start with the currently applied filters, click the button to clear the tags and use all the terms'),
//               controller.selectedTags.isEmpty
//                   ? Container()
//                   : ElevatedButton(
//                       onPressed: () {
//                         controller.selectedTags.clear();
//                         controller.useFavoriteTerms = false;
//                         controller.notifyNoob();
//                         setState(() {});
//                       },
//                       child: const Text('Clear filters')),
//               const SizedBox(
//                 height: 25,
//               ),

//               //old switch selector
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.center,
//               //   children: [
//               //     Text(
//               //       'No',
//               //       style: TextStyle(
//               //           color: controller.useFilteredTerms ? pLight : Colors.black),
//               //     ),
//               //     Switch(
//               //         value: controller.useFilteredTerms,
//               //         onChanged: (onChanged) {
//               //           controller.useFilteredTerms = onChanged;
//               //           setState(() {});
//               //         }),
//               //     Text(
//               //       'Yes',
//               //       style: TextStyle(
//               //           color: controller.useFilteredTerms ? Colors.black : pLight),
//               //     ),
//               //   ],
//               // ),

//               const Text('Select the question and answer configuration'),
//               // Row(
//               //   crossAxisAlignment: CrossAxisAlignment.stretch,
//               //   mainAxisSize: MainAxisSize.min,
//               //   mainAxisAlignment: MainAxisAlignment.center,
//               //   children: [
//               RadioListTile<ExamType>(
//                 title: const Text('Use Terms'),
//                 value: ExamType.useTerms,
//                 groupValue: controller.examType,
//                 onChanged: (ExamType? value) {
//                   setState(() {
//                     controller.examType = value!;
//                   });
//                 },
//               ),

//               RadioListTile<ExamType>(
//                 title: const Text('Use Answers'),
//                 value: ExamType.useAnswers,
//                 groupValue: controller.examType,
//                 onChanged: (ExamType? value) {
//                   setState(() {
//                     controller.examType = value!;
//                   });
//                 },
//               ),

//               RadioListTile<ExamType>(
//                 title: const Text('Mixed'),
//                 value: ExamType.mixed,
//                 groupValue: controller.examType,
//                 onChanged: (ExamType? value) {
//                   setState(() {
//                     controller.examType = value!;
//                   });
//                 },
//               ),
//               //   ],
//               // ),

//               const SizedBox(
//                 height: 20,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (controller.currentGlossaryDocuments.isEmpty) {
//                     Fluttertoast.showToast(
//                         msg:
//                             'There is not terms in the current glossary or with the applied filters');
//                     return;
//                   }
//                   navigateToExam(
//                     'exam',
//                     context,
//                     controller,
//                   );
//                 },
//                 child: const Text('Open Question Exam'),
//               ),

//               controller.currentGlossaryDocuments.length < 4
//                   ? Container()
//                   : ElevatedButton(
//                       onPressed: () {
//                         if (controller.currentGlossaryDocuments.isEmpty) {
//                           Fluttertoast.showToast(
//                               msg:
//                                   'There is not terms in the current glossary or with the applied filters');
//                           return;
//                         }
//                         navigateToExam(
//                           'multipleOption',
//                           context,
//                           controller,
//                         );
//                       },
//                       child: const Text('Multiple Option Exam'),
//                     ),

//               ElevatedButton(
//                   onPressed: () {
//                     if (controller.currentGlossaryDocuments.isEmpty) {
//                       Fluttertoast.showToast(
//                           msg:
//                               'There is not terms in the current glossary or with the applied filters');
//                       return;
//                     }
//                     navigateToExam(
//                       'flashCards',
//                       context,
//                       controller,
//                     );
//                   },
//                   child: const Text('Flash Cards')),
//               OutlinedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//         ));
//   }
// }

//snackbar used to display some options, it is replaced by the bottomnavbar with drawer 
//
// ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 duration: Duration(seconds: 5),
//                 content: ListView(
//                   shrinkWrap: true,
//                   children: [
//                     ListTile(
//                       title: Text('Filter'),
//                       leading: Icon(
//                         Icons.filter_list,
//                         color: colorScheme.onBackground,
//                       ),
//                     ),
//                     ListTile(
//                       title: Text('Difficult Terms'),
//                       leading: Icon(
//                         Icons.donut_large_rounded,
//                         color: colorScheme.onBackground,
//                       ),
//                     ),
//                     ListTile(
//                       title: Text('Exam'),
//                       leading: Icon(
//                         Icons.play_circle_outline_outlined,
//                         color: colorScheme.onBackground,
//                       ),
//                     ),
//                     ListTile(
//                       title: Text('Search'),
//                       leading: Icon(
//                         Icons.search,
//                         color: colorScheme.onBackground,
//                       ),
//                     ),
//                     ListTile(
//                       title: Text('Settings'),
//                       leading: Icon(
//                         Icons.settings,
//                         color: colorScheme.onBackground,
//                       ),
//                     ),
//                   ],
//                 )));

//
//
//
//
//
// all appbar widgetfunctions that got replaced by the bottom nav bar with drawer
   // type == 'glossary'
      //     ? IconButton(
      //         onPressed: () {
      //           showSearch(
      //             context: context,
      //             delegate: CustomSearchDelegate(),
      //           );
      //         },
      //         icon: const Icon(Icons.search))
      //     : Container(),
      // type == 'glossary'
      //     ? IconButton(
      //         onPressed: () {
      //           showDialog(
      //               context: context,
      //               builder: (context) => const DialogStartButton());
      //         },
      //         icon: const Icon(Icons.play_circle_outline_rounded))
      //     : Container(),
      // type == 'glossary'
      //     ? IconButton(
      //         onPressed: () {
      //           Navigator.of(context).pushNamed('/filterGlossaryTermsPage');
      //         },
      //         icon: const Icon(Icons.filter_list))
      //     : Container(),

      //
      //
      //
      //
         //old floating actoin buttons that got replaced for the bottombarwithsheet
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(15.0),
        //   child: Stack(
        //     fit: StackFit.loose,
        //     children: <Widget>[
        //       Align(
        //         alignment: Alignment.bottomLeft,
        //         child: FloatingActionButton(
        //           heroTag: 'difficultTerms',
        //           onPressed: () {
        //             navigateToDifficultTerms(context, controller);
        //           },
        //           child: const Icon(Icons.healing_rounded),
        //         ),
        //       ),
        //       Align(
        //         alignment: Alignment.bottomRight,
        //         child: FloatingActionButton.extended(
        //           heroTag: 'addNewTerms',
        //           onPressed: () {
        //             showDialog(
        //               context: context,
        //               builder: (context) => DialogAddNewTerm(
        //                 glossaryModel: controller.currentGlossary,
        //                 term: TermModel(
        //                     '', '', Type.values.first.toString(), 'untagged'),
        //                 emptyTerm: true,
        //               ),
        //             );
        //           },
        //           label: const Text('New term'),
        //           icon: const Icon(Icons.add_circle_outline),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        //
        //
        //
        //
        //*********important */ old streambuilder used in the glossary page to display the term list
        // StreamBuilder<QuerySnapshot>(
                //   stream: controller.queryStreamCreator(),
                //   builder: (context, snapshot) {
                //     if (snapshot.hasError) {
                //       return const ErrorConnection();
                //     }

                //     if (!snapshot.hasData) {
                //       return const Center(
                //         child: Padding(
                //           padding: EdgeInsets.all(25.0),
                //           child: CircularProgressIndicator(),
                //         ),
                //       );
                //     }

                //     controller.currentGlossaryDocuments = snapshot.data!.docs;

                //     if (controller.currentGlossaryDocuments.isEmpty) {
                //       return Center(
                //         child: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           children: const [
                //             Padding(
                //               padding: EdgeInsets.all(8.0),
                //               child: Text(
                //                 'This glossary does not contain any terms at all or with the current applied filters, would you like to add some to it? Click the add button down below',
                //                 textAlign: TextAlign.center,
                //               ),
                //             ),
                //           ],
                //         ),
                //       );
                //     }

                //     controller.currentTermCount =
                //         controller.currentGlossaryDocuments.length;

                //     return ListViewBuilderTerms(controller: controller);
                //   },
                // ),

                //
                //
                // old list viewbuilder lol might not use this again idk yet
        //
        //
        // ListView.builder(
        //   physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
        //   itemCount: controller.currentGlossaryDocuments.length,
        //   itemBuilder: (context, index) {
        //     TermModel term = TermModel.fromDocumentSnapshot(
        //         controller.currentGlossaryDocuments[index]);
        //     return Slidable(
        //       direction: Axis.horizontal,
        //       actionPane: const SlidableScrollActionPane(),
        //       actions: [
        //         IconSlideAction(
        //           color: Colors.red,
        //           caption: 'Delete',
        //           icon: Icons.delete_forever,
        //           onTap: () {
        //             showDialog(
        //               context: context,
        //               builder: (context) {
        //                 return AlertDialog(
        //                   title: const Text(
        //                       'Are you sure you want to delete this term?'),
        //                   actions: [
        //                     ElevatedButton(
        //                         onPressed: () {
        //                           Navigator.of(context).pop();
        //                         },
        //                         child: const Text('Cancel')),
        //                     ElevatedButton(
        //                         onPressed: () async {
        //                           controller.isLoading = true;
        //                           await controller
        //                               .currentGlossaryDocuments[index].reference
        //                               .delete()
        //                               .onError((error, stackTrace) {});
        //                           Navigator.of(context).pop();
        //                           controller.isLoading = false;
        //                         },
        //                         child: const Text('Delete'))
        //                   ],
        //                 );
        //               },
        //             );
        //           },
        //         ),
        //       ],
        //       child: ListTileTerm(term: term, controller: controller),
        //     );
        //   },
        // ),
        //
        //
        // old method used to edit a term when they were documents before being maps in  an array
          // if (widget.termBackUp!
                                        //         .trim()
                                        //         .capitalize() !=
                                        //     textEditingControllerTerm.text
                                        //         .trim()
                                        //         .capitalize()) {
                                        //   if (!await checkDupeTerm(
                                        //       termsCollectionRef, termName)) {
                                        //     Fluttertoast.showToast(
                                        //         msg: 'This term already exists',
                                        //         toastLength: Toast.LENGTH_LONG);
                                        //     isLoading = false;
                                        //     setState(() {});
                                        //     return;
                                        //   }
                                        // }

                                        // widget.term.term =
                                        //     textEditingControllerTerm.text
                                        //         .capitalize();
                                        // widget.term.answer =
                                        //     textEditingControllerAnswer.text
                                        //         .capitalize();
                                        // widget.term.type = dropdownValue;
                                        // widget.term.tag = dropdownValueTags;

                                        // await widget.term.reference
                                        //     .update(widget.term.toMap());
//
//
//
//old verification method to check if the terms were duped 
//     // if (!await checkDupeTerm(
                                        //     termsCollectionRef, termName)) {
                                        //   Fluttertoast.showToast(
                                        //       msg: 'This term already exists',
                                        //       toastLength: Toast.LENGTH_LONG);

                                        //   return;
                                        // }





//old code used when the terms used to be documents instead of maps
//
//
//
//   // await term.reference
          //     .update({'difficultTerm': false}).onError((error, stackTrace) {
          //   Fluttertoast.showToast(
          //       msg: 'Error updating the results, check your connection',
          //       toastLength: Toast.LENGTH_LONG);
          // }).timeout(const Duration(seconds: 30), onTimeout: () {
          //   Fluttertoast.showToast(
          //       msg: 'Error updating the results, check your connection',
          //       toastLength: Toast.LENGTH_LONG);
          // });
//
//
//
 // await term.reference
          //     .update({'difficultTerm': true}).onError((error, stackTrace) {
          //   Fluttertoast.showToast(
          //       msg: 'Error updating the results, check your connection',
          //       toastLength: Toast.LENGTH_LONG);
          // }).timeout(const Duration(seconds: 30), onTimeout: () {
          //   Fluttertoast.showToast(
          //       msg: 'Error updating the results, check your connection',
          //       toastLength: Toast.LENGTH_LONG);
          // });



//??=
//
   // Row(
                //   crossAxisAlignment: CrossAxisAlignment.stretch,
                //   mainAxisSize: MainAxisSize.min,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [



//
//
//
//
// old code used to add terms when they used to be documents
// // Future addNewTerm(CollectionReference termsCollectionRef) async {
  //   await termsCollectionRef
  //       .add({
  //         'term': termName.capitalize(),
  //         'answer': termAnswer.capitalize(),
  //         'type': dropdownValue,
  //         'tag': dropdownValueTags,
  //         'favoritesList': favorite
  //             ? FieldValue.arrayUnion(['user'])
  //             : FieldValue.arrayUnion([])
  //       })
  //       .then((value) => Fluttertoast.showToast(msg: 'Added a new term'))
  //       .catchError((onError) =>
  //           Fluttertoast.showToast(msg: 'Error, could not add term'));
  // }

  //
  //old function used to check that the terms where not dupes
  //  // Future<bool> checkDupeTerm(
  //     CollectionReference termsCollectionRef, String term) async {
  //   bool status = true;

  //   QuerySnapshot querySnapshot = await termsCollectionRef
  //       .where('term', isEqualTo: term)
  //       .get()
  //       .catchError((onError) {
  //     status = false;
  //     print(onError.toString());
  //   });
  //   if (querySnapshot.docs.isNotEmpty) {
  //     status = false;
  //   }

  //   return status;
  // }




  *Some capitilize function that was not being used anymore
     // String captilize(String string) {
  //   string.replaceRange(1, 1, string.characters.first.toUpperCase());

  //   return "${string[0].toUpperCase()}${string.substring(1)}";
  // }

  */

            


              