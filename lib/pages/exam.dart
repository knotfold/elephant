import 'dart:math';

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

    List<TermModel> termsList = controller.currentTermList;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(args.examType),
        backgroundColor: secondaryColor,
      ),
      body: PageView.builder(
          itemCount: termsList.length,
          physics: args.examType == 'exam'
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          controller: controller.pageControllerExam,
          itemBuilder: (context, index) {
            Widget page;
            switch (args.examType) {
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
              default:
                page = ExamCard(
                  term: termsList[index],
                  index: index,
                );
                break;
            }

            return page;
          }),
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
                  if (checkIfLastPage(controller)) {
                    controller.pageControllerExam.nextPage(
                        duration: const Duration(seconds: 1),
                        curve: const ElasticInCurve());
                  } else {
                    Navigator.of(context).pushReplacementNamed('/examResults');
                  }
                },
                child: checkIfLastPage(controller)
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

  bool checkIfLastPage(Controller controller) {
    bool lastPage = false;
    if (widget.index != controller.currentTermList.length - 1) {
      lastPage = true;
    }
    return lastPage;
  }
}

//this cards have a complicated logic it has many ifs in order to choose if we will use the term or the answer
// as the anchor part to the card, so we have 3 variables to check if the exam will be mixed, or if it will normal,
// or based on answers, the same logic needs to be implemented for the flashcards and the open exams
class ExamCardMultipleOption extends StatelessWidget {
  final TermModel term;
  const ExamCardMultipleOption({Key? key, required this.term})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    String answer = '';
    bool useTerms = true;
    if (controller.testFromAnswers) {
      useTerms = false;
      answer = term.term;
    } else if (controller.testFromTerms) {
      answer = term.answer;
    } else if (controller.mixTermsAnswers) {
      int i = Random().nextInt(1);
      if (i % 2 == 0) {
        useTerms = true;
        answer = term.answer;
      } else {
        useTerms = false;
        answer = term.term;
      }
    }

    List<String> options = multipleOptionMaker(controller, answer, useTerms);
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(term.term),
          ListView.builder(itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                if (answer == options[index]) {
                  print(true);
                }
              },
              title: Text(options[index]),
            );
          })
        ],
      ),
    );
  }
}

List<String> multipleOptionMaker(
    Controller controller, String answer, bool terms) {
  List<String> options = [];

  List<TermModel> currentTermList = controller.currentTermList;

  options.add(answer);

  for (int index = 0; index < 3; index++) {
    int randomIndex = Random().nextInt(currentTermList.length);
    if (!terms) {
      options.add(currentTermList[randomIndex].term);
    }

    if (terms) {
      options.add(currentTermList[randomIndex].answer);
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

  return options;
}
