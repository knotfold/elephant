import 'package:elephant/pages/pages.dart';
import 'package:elephant/services/services.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

//this page is in charge of letting the user choose different settings for the exam
class ExamSettingsPage extends StatefulWidget {
  const ExamSettingsPage({Key? key}) : super(key: key);

  @override
  State<ExamSettingsPage> createState() => _ExamSettingsPageState();
}

class _ExamSettingsPageState extends State<ExamSettingsPage> {
  //texteditcontroll that handles the input of the user when choosing the examlength
  TextEditingController textEditingControllerExamLength =
      TextEditingController(text: 0.toString());

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    //text style for the title
    final textStyleTheme = Theme.of(context).textTheme.headline3;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: myAppBar(
          context: context, type: 'examSettings', title: 'Exam Preparation'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 15,
                ),
                //Title of the page
                Text(
                  'Exam settings',
                  style:
                      textStyleTheme?.copyWith(color: colorScheme.onBackground),
                ),
                const SizedBox(height: 10),
                //Displays a warning text if the selectedtags happens to be not empty or
                //if the user is using the favorite terms option
                controller.selectedTags.isNotEmpty ||
                        controller.useFavoriteTerms
                    ? const Text(
                        'Exam and flash cards will start with the currently applied filters, click the button to clear the tags and use all the terms')
                    : Container(),
                //displays a button based on the conditions below
                controller.selectedTags.isNotEmpty ||
                        controller.useFavoriteTerms
                    ? ElevatedButton(
                        //clears tags and favorite status
                        onPressed: () {
                          controller.selectedTags.clear();
                          controller.useFavoriteTerms = false;
                          controller.notifyNoob();
                          setState(() {});
                        },
                        child: const Text('Clear filters'),
                      )
                    : Container(),
                const SizedBox(
                  height: 40,
                ),
                const Text('Select the question and answer configuration'),
                //radios list tile of the different question and answer config
                RadioListTile<ExamType>(
                  title: const Text('Use Terms'),
                  value: ExamType.useTerms,
                  groupValue: controller.examType,
                  onChanged: (ExamType? value) {
                    setState(() {
                      controller.examType = value!;
                    });
                  },
                ),

                RadioListTile<ExamType>(
                  title: const Text('Use Answers'),
                  value: ExamType.useAnswers,
                  groupValue: controller.examType,
                  onChanged: (ExamType? value) {
                    setState(() {
                      controller.examType = value!;
                    });
                  },
                ),

                RadioListTile<ExamType>(
                  title: const Text('Mixed'),
                  value: ExamType.mixed,
                  groupValue: controller.examType,
                  onChanged: (ExamType? value) {
                    setState(() {
                      controller.examType = value!;
                    });
                  },
                ),

                const SizedBox(
                  height: 40,
                ),
                const Text('Enable or disable exam custom length'),
                //row with a switch that lets the user choose if the want to use a fixed length for the exam
                Row(
                  children: [
                    Switch(
                        inactiveTrackColor: Colors.grey,
                        inactiveThumbColor: Colors.grey,
                        value: controller.useFixedLength,
                        onChanged: (value) {
                          controller.useFixedLength = value;
                          controller.notifyNoob();
                        }),
                    Text(
                        'Max length: ${controller.listAssignerFunction().length}')
                  ],
                ),
                //textfield where the user can input the desired fixed length, which can never be more than the list
                //length there for it was a logic for the value to always be an int and to never be more than the length
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  controller: textEditingControllerExamLength,
                  enabled: controller.useFixedLength,
                  onChanged: (value) {
                    //it is always necessary to get the lermlist to check what is the max length an exam can have depending on the filters applied or if it is not filtered
                    //trusting the list assigner function is the way
                    List<TermModel> termsList =
                        controller.listAssignerFunction();

                    int intValue = int.tryParse(value.trim()) ?? 0;
                    if (intValue > termsList.length) {
                      textEditingControllerExamLength.text =
                          termsList.length.toString();
                      return;
                    }
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text('Choose the type of exam'),
                //button bar with the different exam options, each button displays an error if clicked and the list of terms
                //is empty
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    //button for the open question exams
                    ElevatedButton(
                      onPressed: () {
                        if (controller.listAssignerFunction().isEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  'There is not terms in the current glossary or with the applied filters');
                          return;
                        }
                        navigateToExam('exam', context, controller,
                            examLength: int.parse(
                                textEditingControllerExamLength.text));
                      },
                      child: const Text('Open Question Exam'),
                    ),
                    //if the current glossary terms list length is less than 4 it doesnt show the button
                    controller.listAssignerFunction().length < 4
                        ? Container()
                        : ElevatedButton(
                            onPressed: () {
                              if (controller
                                  .currentGlossary.termsMapList.isEmpty) {
                                Fluttertoast.showToast(
                                    msg:
                                        'There is not terms in the current glossary or with the applied filters');
                                return;
                              }
                              navigateToExam(
                                'multipleOption',
                                context,
                                controller,
                                examLength: int.parse(
                                    textEditingControllerExamLength.text.isEmpty
                                        ? '0'
                                        : textEditingControllerExamLength.text),
                              );
                            },
                            child: const Text('Multiple Option Exam'),
                          ),
                    //flash cards btn
                    ElevatedButton(
                        onPressed: () {
                          if (controller.listAssignerFunction().isEmpty) {
                            Fluttertoast.showToast(
                                msg:
                                    'There is not terms in the current glossary or with the applied filters');
                            return;
                          }
                          navigateToExam('flashCards', context, controller,
                              examLength: int.parse(
                                  textEditingControllerExamLength.text));
                        },
                        child: const Text('Flash Cards')),
                  ],
                ),

                const SizedBox(
                  height: 15,
                ),
                //return button?
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go back'),
                ),
              ]),
        ),
      ),
    );
  }

  //this function navigates to the exam page, it recieves the exam type and the controller, and the examLength
  navigateToExam(String type, BuildContext context, Controller controller,
      {required int examLength}) async {
    //before navigating makes a transation that updates the current glossary
    //to let the other users know that someone is in the exam
    await controller.currentGlossaryTransaction(() {
      if (controller.currentGlossary.usersInExamList.contains('user')) {
        return;
      }
      controller.currentGlossary.usersInExamList.add('user');
    });

    //resets some variables in the controller
    controller.resetControllerVars();
    //gets the exam length
    controller.fixedExamLength = examLength;
    //generates the currentTermList
    controller.currentTermList = controller.listAssignerFunction().toList();
    //shuffles currentTermList
    controller.currentTermList.shuffle();

    //Navigates to the exam page
    Navigator.of(context).pushReplacementNamed(ExamPage.routeName,
        //exam arguments
        arguments: ExamArguments(
          examType: type,
        ));
  }
}
