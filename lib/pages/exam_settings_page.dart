import 'package:elephant/pages/pages.dart';
import 'package:elephant/services/services.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ExamSettingsPage extends StatefulWidget {
  const ExamSettingsPage({Key? key}) : super(key: key);

  @override
  State<ExamSettingsPage> createState() => _ExamSettingsPageState();
}

class _ExamSettingsPageState extends State<ExamSettingsPage> {
  TextEditingController textEditingControllerExamLength =
      TextEditingController(text: 0.toString());

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleTheme = Theme.of(context).textTheme.headline6;

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
                Text(
                  'Select the exam configuration',
                  style: textStyleTheme,
                ),
                const SizedBox(height: 30),
                controller.selectedTags.isNotEmpty ||
                        controller.useFavoriteTerms
                    ? const Text(
                        'Exam and flash cards will start with the currently applied filters, click the button to clear the tags and use all the terms')
                    : Container(),
                controller.selectedTags.isNotEmpty ||
                        controller.useFavoriteTerms
                    ? ElevatedButton(
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
                  height: 25,
                ),
                const Text('Select the question and answer configuration'),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.stretch,
                //   mainAxisSize: MainAxisSize.min,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
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
                //   ],
                // ),

                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Text('Use fixed length'),
                    Switch(
                        inactiveTrackColor: Colors.grey,
                        inactiveThumbColor: Colors.grey,
                        value: controller.useFixedLength,
                        onChanged: (value) {
                          controller.useFixedLength = value;
                          controller.notifyNoob();
                        }),
                    Text(
                        'Max length: ${controller.currentGlossaryDocuments.length}')
                  ],
                ),

                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  controller: textEditingControllerExamLength,
                  enabled: controller.useFixedLength,
                  onChanged: (value) {
                    if (int.parse(value) >
                        controller.currentGlossaryDocuments.length) {
                      textEditingControllerExamLength.text =
                          controller.currentGlossaryDocuments.length.toString();
                    }
                  },
                ),

                ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (controller.currentGlossaryDocuments.isEmpty) {
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
                    controller.currentGlossaryDocuments.length < 4
                        ? Container()
                        : ElevatedButton(
                            onPressed: () {
                              if (controller.currentGlossaryDocuments.isEmpty) {
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
                                    textEditingControllerExamLength.text),
                              );
                            },
                            child: const Text('Multiple Option Exam'),
                          ),
                    ElevatedButton(
                        onPressed: () {
                          if (controller.currentGlossaryDocuments.isEmpty) {
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
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ]),
        ),
      ),
    );
  }

  navigateToExam(String type, BuildContext context, Controller controller,
      {required int examLength}) {
    Navigator.of(context).pop();
    controller.resetControllerVars();
    controller.generateCurrentTermsList(examLength: examLength);

    Navigator.of(context).pushNamed(ExamPage.routeName,
        arguments: ExamArguments(
          examType: type,
        ));
  }
}
