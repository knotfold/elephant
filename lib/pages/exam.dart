import 'dart:async';
import 'dart:math';

import 'package:elephant/pages/exam_results.dart';
import 'package:elephant/pages/pages.dart';
import 'package:elephant/services/controller.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:elephant/services/models.dart';
import 'package:provider/provider.dart';

//This page is in charge of displaying the exam to the user
//it has a lot of widgets and gimmicks so it is a bit difficult to modify

//the class requieres to recieve a examtype which dictates its fuctionality
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
    //recieves the arguments of the constructor
    final args = ModalRoute.of(context)!.settings.arguments as ExamArguments;
    Controller controller = Provider.of<Controller>(context);
    //this list is in charge of telling the exam which terms is going to use,
    //depending on its type it chooses from the difficultTermList or the
    //currentTermslist which is the list specially made for the exam
    List<TermModel> termsList = args.examType == 'difficultExam' ||
            args.examType == 'difficultFlashCards'
        ? controller.difficultTermList
        : controller.currentTermList;

    //lets the controller know if it is a difficult exam or no
    controller.difficultExam = args.examType == 'difficultExam';

    //handles the real exam length, if the controller fixedLength is not
    //equal to the termlist length and the fixedlength is not 0, this means that the exam
    //has a custom length, there for it should display less terms so the exam length is the fixedlength
    controller.realFixedExamLength =
        termsList.length != controller.fixedExamLength &&
                controller.fixedExamLength != 0
            ? controller.fixedExamLength
            : termsList.length;
    return WillPopScope(
      onWillPop: () async {
        //if the scope will be poped it resets some vars in the controller and also runs a
        //transaction to update the currentglossary users in exam status
        //removing the user of the list, this meaning he is not inside an exam anymore
        controller.fixedExamLength = 0;
        controller.realFixedExamLength = 0;
        controller.currentGlossaryTransaction(() {
          controller.currentGlossary.usersInExamList.remove('user');
        });

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            //if the exam is a flashCard type it show an special icon button in the appbar
            //this icon button displays the list of terms in a dialog
            args.examType == 'flashCards' ||
                    args.examType == 'difficultFlashCards'
                ? IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return DialogFindTermIndex(
                              termsList: termsList,
                            );
                          });
                    },
                    icon: const Icon(Icons.find_in_page))
                : Container(),
          ],
          //the titile of the appbar is the exam type lol, it shouldn't be like this
          title: const Text(
            'Exam',
          ),
        ),
        //pageview builder that displays all the exam questions
        body: PageView.builder(
            itemCount: controller.realFixedExamLength,
            //checks if the exam is not a flashcard type exam and if it isn't
            //disables the scrool physics
            physics: args.examType == 'exam' ||
                    args.examType == 'multipleOption' ||
                    args.examType == 'difficultExam'
                ? const NeverScrollableScrollPhysics()
                : const ScrollPhysics(),
            controller: controller.pageControllerExam,
            itemBuilder: (context, index) {
              //the pages of the exam
              Widget page;
              //this switch allocates the right page type to the page widget based on the exam type
              switch (args.examType) {
                //assigns the page widget an examcard witdget
                case 'difficultExam':
                  page = ExamCard(
                    term: controller.difficultTermList[index],
                    index: index,
                  );
                  break;
                //assigns the page widget a flashcard widget
                case 'difficultFlashCards':
                  page = FlashCard(
                    term: controller.difficultTermList[index],
                    page: index,
                    length: controller.realFixedExamLength,
                  );
                  break;
                //assigns the page witget an  examcard widget
                case 'exam':
                  page = ExamCard(
                    term: termsList[index],
                    index: index,
                  );
                  break;
                //assigns the page widget a flashcard widget
                case 'flashCards':
                  page = FlashCard(
                    term: termsList[index],
                    page: index,
                    length: controller.realFixedExamLength,
                  );
                  break;
                //assigns the page widget an examCardMultipleOption widget
                case 'multipleOption':
                  page = ExamCardMultipleOption(
                      term: termsList[index], indexPageController: index);
                  break;
                // assigns the page widget an examcard widget by default
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

class DialogFindTermIndex extends StatelessWidget {
  //this dialog displays the list  of the flashcard exam and helps the user
  //navigate the exam, it recieves the currently used list and works with the
  //controller fixedexamlength
  final List<TermModel> termsList;
  const DialogFindTermIndex({Key? key, required this.termsList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListView.builder(
        itemCount: controller.realFixedExamLength,
        itemBuilder: (context, index) {
          TermModel termModel = termsList[index];
          return ListTile(
            title: Text(termModel.term),
            trailing: Text((index + 1).toString()),
            onTap: () {
              int ind = index;
              nextPage(controller, ind, true);
              Navigator.of(context).pop();
            },
          );
        },
        padding: const EdgeInsets.all(20),
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
    final textStyleLongTerm = Theme.of(context).textTheme.headline4;
    // final textStyleTermType = Theme.of(context).textTheme.subtitle2;
    // ColorScheme colorScheme = Theme.of(context).colorScheme;

    // final textStyleAnswer = Theme.of(context).textTheme.headline6;

    int chars = widget.term.term.characters.length;
    bool useLongTextStyle = chars > 45;
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
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary)),
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(
                      //   controller.termIconAsignner(widget.term.type),
                      //   size: 40,
                      // ),
                      IconButtonFavoriteTerm(
                          controller: controller, term: widget.term),
                      TermTypeDisplayText(
                        termModel: widget.term,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.term.term,
                    style: useLongTextStyle ? textStyleLongTerm : textStyleTerm,
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  uncoverText ? Text(widget.term.answer) : Container(),
                  const SizedBox(
                    height: 60,
                  ),
                  Text(' ${widget.page + 1}/${widget.length}'),
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
                    height: 30,
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
    final textStyleLongTerm = Theme.of(context).textTheme.headline4;
    int chars = widget.term.term.characters.length;
    bool useLongTextStyle = chars > 45;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   controller.termIconAsignner(widget.term.type),
                  //   size: 40,
                  // ),
                  IconButtonFavoriteTerm(
                      controller: controller, term: widget.term),
                  TermTypeDisplayText(
                    termModel: widget.term,
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.term.term,
                style: useLongTextStyle ? textStyleLongTerm : textStyleAnswer,
              ),
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
      ),
    );
  }
}

bool checkIfLastPage(Controller controller, int index) {
  bool lastPage = true;
  if (index != controller.realFixedExamLength - 1) {
    lastPage = false;
  }
  return lastPage;
}

void nextPage(Controller controller, int index, bool jump) {
  //jump is used to determine if i want to jump to a certain page or just go to the next one, it being true means that i want to jump
  //to the exact number
  int page = jump ? index : index + 1;
  controller.pageControllerExam.animateToPage(page,
      duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
}

void navigationInExam(
    {required BuildContext context,
    required Controller controller,
    required int index}) {
  if (!checkIfLastPage(controller, index)) {
    nextPage(controller, index, false);
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
  //used to controll the page index
  final int indexPageController;

  const ExamCardMultipleOption(
      {Key? key, required this.term, required this.indexPageController})
      : super(key: key);

  @override
  State<ExamCardMultipleOption> createState() => _ExamCardMultipleOptionState();
}

class _ExamCardMultipleOptionState extends State<ExamCardMultipleOption> {
  Color tileColor = primary;
  bool useTerms = true;
  List<String> options = [];
  String? answer;

  @override
  Widget build(BuildContext context) {
    final textStyleTerm = Theme.of(context).textTheme.headline2;
    final textStyleLongTerm = Theme.of(context).textTheme.headline4;

    Controller controller = Provider.of(context);

    // the answer and options variables only get rebuild when the tilestatus is positive again, this status is handled in the answertile and
    //it is set to negative when the tile is clicked and set to positive again on navigation.
    //if the controller update star is set to true this means that the favorite status needs to be updated.
    //there for the others stuff doesnt need to happen so if it is true it skips the if
    //lastly if the options list is empty it just does it by default, this is basically and if in charge of
    //building the multiple options for the multiple option exam

    if (controller.tileStatus && !controller.updateStar || options.isEmpty) {
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
      options = multipleOptionMaker(controller, answer!, useTerms);
    }

    //when the widget launches sets the controller updatestar variable to false, this is to
    //to let know the code that the favorite status has already been updated, and everything can
    //function as needed

    controller.updateStar = false;

    //this variable is the text to display during the exam, which is the guide text
    String textToDisplayVar = textToDisplay(widget.term, useTerms);
    //this int gets the size of the text, depending on its amount of characters
    //the text will be rezized
    int chars = textToDisplayVar.characters.length;
    bool useLongTextStyle = chars > 40;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //row that works as a guide for the person presenting the exam
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   controller.termIconAsignner(widget.term.type),
              //   size: 40,
              // ),
              IconButtonFavoriteTerm(controller: controller, term: widget.term),
              TermTypeDisplayText(
                termModel: widget.term,
              ),
            ],
          ),
          Flexible(
            child: Text(
              textToDisplayVar,
              style: useLongTextStyle ? textStyleLongTerm : textStyleTerm,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          const Text('Select the right option'),
          const SizedBox(
            height: 5,
          ),
          //list vies builder of the different options for the question
          ListView.builder(
              padding: const EdgeInsets.all(15),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return MultipleOptionTile(
                    answer: answer!,
                    options: options,
                    index: index,
                    term: widget.term,
                    indexPageController: widget.indexPageController);
              })
        ],
      ),
    );
  }
}

//the multiple option tile widget is the widget that handles the multiple option exam
//options
class MultipleOptionTile extends StatefulWidget {
  //it recieves the answer, the term and the list of options that was generated previously when the
  //multiple option page was being build. it also gets the index of the page and the controller?
  final String answer;
  final List<String> options;
  //index of the options list
  final int index;
  final TermModel term;
  //index of the current exam page
  final int indexPageController;

  const MultipleOptionTile(
      {Key? key,
      required this.answer,
      required this.options,
      required this.index,
      required this.term,
      required this.indexPageController})
      : super(key: key);

  @override
  State<MultipleOptionTile> createState() => _MultipleOptionTileState();
}

class _MultipleOptionTileState extends State<MultipleOptionTile> {
  //this secondary color is used for the tile color
  Color color = secondaryColor;
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    //this returns a listtile with different widgets and functionalities.
    return ListTile(
      //if the tile status is true, this will not show a thing, but when it is clicked
      //the tile states is set to false this allowing the tile to show if the answer
      //is right or wrong based on the user input
      leading: controller.tileStatus
          ? const SizedBox(
              width: 1,
              height: 1,
            )
          : Icon(
              widget.answer == widget.options[widget.index]
                  ? Icons.check_circle_outlined
                  : Icons.cancel_outlined,
              color: controller.tileColor,
            ),
      //is enable depending on the tilestatus
      enabled: controller.tileStatus,
      onTap: () {
        //on tap imediately the tile status is set to false to calculate the results of the chosen answer
        controller.tileStatus = false;
        //if the answer and the option match it gives the tile color the secondary color and adds the term to the rightterms list
        //this list helps with the results of the exam
        //if they do not match the color is set to red and the term is added to the wrong terms list
        if (widget.answer == widget.options[widget.index]) {
          controller.tileColor = secondaryColor;
          controller.rightTerms.add(widget.term);
        } else {
          controller.tileColor = Colors.red;
          setState(() {});
          controller.wrongTerms.add(widget.term);
        }
        //updates the controller variables
        controller.notifyNoob();

        //timer that lets the user ccheck the answer results, after 3 seconds it automatically navigates to the next page
        Timer(const Duration(seconds: 3), () {
          controller.tileStatus = true;

          navigationInExam(
              context: context,
              controller: controller,
              index: widget.indexPageController);
        });
      },
      title: Text(widget.options[widget.index]),
    );
  }
}

//returns a string depending on the useTerms bool which tells the code
//to use the term as the display or the answer
String textToDisplay(TermModel term, bool useTerms) {
  String text = useTerms ? term.term : term.answer;

  return text;
}

//makes multiple options for the exam, the answer is the answer for the questions and the terms
//bool lets the code know if the list needs to be made with terms of with answers
List<String> multipleOptionMaker(
    Controller controller, String answer, bool useAnswers) {
  //generates a empty list to be filled with the different options
  List<String> options = [];

  //list created to have cleaner code
  List<TermModel> currentTermList = controller.unfilteredTermList;

  //the answer is added automatically to the list
  options.add(answer);

  //this for is executed until the list has 4 strings to display
  for (int index = 0; index < 3; index++) {
    //we get a randomIndex to get a random term from our list
    int randomIndex = Random().nextInt(currentTermList.length);
    //if useAnawers is set to false this means we are using the termfield
    // to fill our list
    if (!useAnswers) {
      //this if checks that the options doesnt contain already the same answer in case of it not containing it
      //it adds the option to the list, if it is already there it rests the index value of the cycle to make it lap again
      if (!options.contains(currentTermList[randomIndex].term)) {
        options.add(currentTermList[randomIndex].term);
      } else {
        index--;
      }
    }
    //checks if the useanswers is true and fills the options list with the
    //answer field of a term, same as before checks that the options are not duped
    if (useAnswers) {
      if (!options.contains(currentTermList[randomIndex].answer)) {
        options.add(currentTermList[randomIndex].answer);
      } else {
        index--;
      }
    }
  }

  //shuffles the list so the answer is not always the first one
  options.shuffle();

  //returns the options list
  return options;
}
