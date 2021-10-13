import 'dart:async';
import 'dart:math';

import 'package:elephant/pages/exam_results.dart';
import 'package:elephant/services/controller.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:elephant/services/models.dart';
import 'package:provider/provider.dart';

class ExamArguments {
  final String examType;

  ExamArguments({required this.examType});
}

class ExamPage extends StatefulWidget {
  static const routeName = '/exam';
  const ExamPage({Key? key}) : super(key: key);

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ExamArguments;
    Controller controller = Provider.of<Controller>(context);

    List<TermModel> termsList = args.examType == 'difficultExam'
        ? controller.difficultTermList
        : controller.currentTermList;

    controller.difficultExam = args.examType == 'difficultExam';

    return WillPopScope(
      onWillPop: () async {
        controller.currentTermList.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(args.examType.toUpperCase()),
          backgroundColor: secondaryColor,
        ),
        body: PageView.builder(
            itemCount: termsList.length,
            physics: args.examType == 'exam' ||
                    args.examType == 'multipleOption' ||
                    args.examType == 'difficultExam'
                ? const NeverScrollableScrollPhysics()
                : const ScrollPhysics(),
            controller: controller.pageControllerExam,
            itemBuilder: (context, index) {
              Widget page;
              switch (args.examType) {
                case 'difficultExam':
                  page = ExamCard(
                    term: controller.difficultTermList[index],
                    index: index,
                  );
                  break;
                case 'exam':
                  page = ExamCard(
                    term: termsList[index],
                    index: index,
                  );
                  break;
                case 'flashCards':
                  page = FlashCard(
                    term: termsList[index],
                    page: index,
                    length: termsList.length,
                  );
                  break;
                case 'multipleOption':
                  page = ExamCardMultipleOption(
                      term: termsList[index], indexPageController: index);
                  break;
                default:
                  page = ExamCard(
                    term: termsList[index],
                    index: index,
                  );
                  break;
              }

              return page;
            }),
      ),
    );
  }
}

class FlashCard extends StatefulWidget {
  final TermModel term;
  final int page;
  final int length;
  const FlashCard(
      {Key? key, required this.term, required this.page, required this.length})
      : super(key: key);

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  bool uncoverText = false;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleTerm = Theme.of(context).textTheme.headline2;
    final textStyleAnswer = Theme.of(context).textTheme.headline6;
    // TODO: implement build
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                uncoverText = true;
              });
            },
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: sDark)),
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.termIconAsignner(widget.term.type),
                    size: 40,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.term.term,
                    style: textStyleTerm,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  uncoverText ? Text(widget.term.answer) : Container(),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       uncoverText = true;
                  //     });
                  //   },
                  //   child: Text(
                  //     widget.term.answer,
                  //     style: TextStyle(
                  //         backgroundColor:
                  //             !uncoverText ? Colors.black : Colors.transparent),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
          widget.page == 0 && widget.length > 1
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Swipe to slide'),
                    Icon(Icons.swipe_sharp),
                    SizedBox(
                      height: 30,
                    ),
                    Text('Click on the answer to uncover it'),
                    Icon(Icons.remove_red_eye)
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class ExamCard extends StatefulWidget {
  final TermModel term;
  final int index;

  const ExamCard({Key? key, required this.term, required this.index})
      : super(key: key);

  @override
  State<ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  final formKey = GlobalKey<FormState>();
  int mistakeCounter = 0;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleAnswer = Theme.of(context).textTheme.headline3;
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face_rounded),
            const SizedBox(
              height: 15,
            ),
            Text(widget.term.term),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              enabled: mistakeCounter < 3,
              validator: (value) {
                if (value == '') {
                  return 'Write an answer';
                }
                if (value!.trim().toLowerCase() !=
                        widget.term.answer.trim().toLowerCase() &&
                    mistakeCounter < 3) {
                  mistakeCounter++;
                  setState(() {});

                  return 'Wrong answer';
                }
              },
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            mistakeCounter > 2
                ? Text(
                    widget.term.answer,
                    style: textStyleAnswer,
                  )
                : Container(),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  formKey.currentState!.save();
                  if (mistakeCounter < 3) {
                    controller.rightTerms.add(widget.term);
                  } else {
                    controller.wrongTerms.add(widget.term);
                  }

                  navigationInExam(
                      context: context,
                      controller: controller,
                      index: widget.index);
                },
                child: !checkIfLastPage(controller, widget.index)
                    ? const Text('Next question')
                    : const Text('Finish exam')),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}

bool checkIfLastPage(Controller controller, int index) {
  bool lastPage = true;
  if (index !=
      (controller.difficultExam
              ? controller.difficultTermList.length
              : controller.currentTermList.length) -
          1) {
    lastPage = false;
  }
  return lastPage;
}

void nextPage(Controller controller, int index) {
  controller.pageControllerExam.animateToPage(index + 1,
      duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
}

void navigationInExam(
    {required BuildContext context,
    required Controller controller,
    required int index}) {
  if (!checkIfLastPage(controller, index)) {
    nextPage(controller, index);
    // controller.pageControllerExam.nextPage(
    //     duration: const Duration(seconds: 1), curve: const ElasticInCurve());
  } else {
    Navigator.of(context).pushReplacementNamed(ExamResultPage.routeName,
        arguments:
            ExamResultArguments(difficultTerms: controller.difficultExam));
  }
}

//this cards have a complicated logic it has many ifs in order to choose if we will use the term or the answer
// as the anchor part to the card, so we have 3 variables to check if the exam will be mixed, or if it will normal,
// or based on answers, the same logic needs to be implemented for the flashcards and the open exams
class ExamCardMultipleOption extends StatefulWidget {
  final TermModel term;
  final int indexPageController;

  const ExamCardMultipleOption(
      {Key? key, required this.term, required this.indexPageController})
      : super(key: key);

  @override
  State<ExamCardMultipleOption> createState() => _ExamCardMultipleOptionState();
}

class _ExamCardMultipleOptionState extends State<ExamCardMultipleOption> {
  bool tileEnabled = true;
  Color tileColor = primary;
  bool useTerms = true;

  @override
  Widget build(BuildContext context) {
    final textStyleTerm = Theme.of(context).textTheme.headline2;
    Controller controller = Provider.of(context);
    String answer = '';
    switch (controller.examType) {
      case ExamType.useTerms:
        answer = widget.term.answer;
        break;
      case ExamType.useAnswers:
        useTerms = false;
        answer = widget.term.term;
        break;
      case ExamType.mixed:
        int i = Random().nextInt(2);
        if (i % 2 == 0) {
          useTerms = true;
          answer = widget.term.answer;
        } else {
          useTerms = false;
          answer = widget.term.term;
        }
        break;
    }

    // if (controller.testFromAnswers) {
    //   useTerms = false;
    //   answer = widget.term.term;
    // } else if (controller.testFromTerms) {
    //   answer = widget.term.answer;
    // } else if (controller.mixTermsAnswers) {
    //   int i = Random().nextInt(1);
    //   if (i % 2 == 0) {
    //     useTerms = true;
    //     answer = widget.term.answer;
    //   } else {
    //     useTerms = false;
    //     answer = widget.term.term;
    //   }
    // }

    List<String> options = multipleOptionMaker(controller, answer, useTerms);
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            textToDisplay(widget.term, useTerms),
            style: textStyleTerm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 15,
          ),
          const Text('Select the right option'),
          const SizedBox(
            height: 5,
          ),
          ListView.builder(
              padding: const EdgeInsets.all(15),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  enabled: tileEnabled,
                  tileColor: tileColor,
                  onTap: () {
                    tileEnabled = false;
                    if (answer == options[index]) {
                      controller.rightTerms.add(widget.term);
                      tileColor = Colors.green;
                    } else {
                      controller.wrongTerms.add(widget.term);
                      tileColor = Colors.red;
                    }
                    setState(() {});
                    Timer(const Duration(seconds: 1), () {
                      navigationInExam(
                          context: context,
                          controller: controller,
                          index: widget.indexPageController);
                    });
                  },
                  title: Text(options[index]),
                );
              })
        ],
      ),
    );
  }
}

String textToDisplay(TermModel term, bool useTerms) {
  String text = useTerms ? term.term : term.answer;

  return text;
}

List<String> multipleOptionMaker(
    Controller controller, String answer, bool terms) {
  List<String> options = [];

  List<TermModel> currentTermList = controller.currentTermList;

  options.add(answer);

  for (int index = 0; index < 3; index++) {
    int randomIndex = Random().nextInt(currentTermList.length);
    if (!terms) {
      if (!options.contains(currentTermList[randomIndex].term)) {
        options.add(currentTermList[randomIndex].term);
      } else {
        index--;
      }
    }

    if (terms) {
      if (!options.contains(currentTermList[randomIndex].answer)) {
        options.add(currentTermList[randomIndex].answer);
      } else {
        index--;
      }
    }

    // if (controller.mixTermsAnswers) {
    //   int i = Random().nextInt(1);
    //   if (i % 2 == 0) {
    //     options.add(currentTermList[randomIndex].term);
    //   } else {
    //     options.add(currentTermList[randomIndex].answer);
    //   }
    // }
  }

  options.shuffle();

  return options;
}
