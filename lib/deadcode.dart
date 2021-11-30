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