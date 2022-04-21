import 'package:elephant/services/services.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:provider/provider.dart';

//This page is in charge of displaying the exam results. it show the user its total score and
// the wrong and right answers
class ExamResultArguments {
  //checks if the exam was a difficult term exam or a normal exam
  final bool difficultTerms;

  ExamResultArguments({required this.difficultTerms});
}

class ExamResultPage extends StatelessWidget {
  static const routeName = '/examResults';

  const ExamResultPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Arguments recived when navigating to this page
    final args =
        ModalRoute.of(context)!.settings.arguments as ExamResultArguments;

    Controller controller = Provider.of<Controller>(context);
    //gets the right answers
    List<TermModel> rightTermsList = controller.rightTerms;
    //gets the wrong answers
    List<TermModel> wrongTermsList = controller.wrongTerms;
    //gets the amount of right answers
    int rightAnswers = rightTermsList.length;
    //gets the amount of wrong answers
    int wrongAnswers = wrongTermsList.length;
    //gets the total of questions
    int total = controller.realFixedExamLength;
    //gets the percentage obtained in the exam
    int totalPercentage = (rightAnswers / total * 100).round();
    //text style for the mini headers on each list
    final textStyle1 = Theme.of(context).textTheme.headline6;
    //text style for the final score
    final textStyleFinalScore = Theme.of(context).textTheme.headline6;
    //text style for the 4 score
    final textStylescore4Scale = Theme.of(context).textTheme.headline1;

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      //resets the controller variables
      onWillPop: () async {
        if (controller.isLoading) return false;
        controller.fixedExamLength = 0;
        controller.realFixedExamLength = 0;
        controller.resetControllerVars();

        return true;
      },
      child: Scaffold(
        appBar: myAppBar(context: context, type: 'Exam Results'),
        //This future builder helps load the wrong and right answers to the database
        //and helps with the scoring
        body: FutureBuilder<bool>(
            //load the wrong and right answers to the database
            future: updateDifficultTerms(controller, args.difficultTerms),
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: const [
                        Text('Loading results'),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }

              if (!asyncSnapshot.data!) {
                return const ErrorConnection();
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //This texts show how many right answers and the total
                      Text(
                        'Score: $rightAnswers/$total',
                        style: textStyleFinalScore,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //circle avatar to display the 4 score in a cool way.
                      CircleAvatar(
                        foregroundColor: colorScheme.secondary,
                        backgroundColor: colorScheme.secondary,
                        maxRadius: 80,
                        child: Text(
                          assing4Score(totalPercentage),
                          style: textStylescore4Scale,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //gives a phrase depending on the result obtained
                      Text(
                        assignPhrase(totalPercentage),
                        style: textStylescore4Scale,
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      //its the title to the wrong answers list
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cancel_outlined),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Wrong answers: $wrongAnswers',
                            style: textStyle1,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      //list of all the wrong answers
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: wrongTermsList.length,
                          itemBuilder: (context, index) {
                            TermModel term = wrongTermsList[index];
                            return ListTile(
                              leading:
                                  Icon(controller.termIconAsignner(term.type)),
                              title: Text(term.term),
                              subtitle: Text(term.answer),
                            );
                          }),
                      const SizedBox(
                        height: 25,
                      ),
                      //title row for the correct answers list
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outlined,
                            color: secondaryColor,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Correct answers: $rightAnswers',
                            style: textStyle1,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      //list of all the correct answers
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: rightTermsList.length,
                        itemBuilder: (context, index) {
                          TermModel term = rightTermsList[index];
                          return ListTile(
                            leading:
                                Icon(controller.termIconAsignner(term.type)),
                            title: Text(term.term),
                            subtitle: Text(term.answer),
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  //load the wrong and right answers to the database, recieves a controller and the difficultterms bool.
  Future<bool> updateDifficultTerms(
      Controller controller, bool difficultTerms) async {
    //puts the app in loading state
    controller.isLoading = true;
    //this will be returned to let know if the update was succesfull or no
    bool updated = true;
    //the updated bool awaits the result of the transaction
    updated = await controller.currentGlossaryTransaction(() {
      //if the exam is a difficult term exam, then it removes the user from the
      //difficcult term list so the term can now be removed from it
      if (difficultTerms) {
        //loops through every term in the righttermlist
        for (var term in controller.rightTerms) {
          term.usersListDifficultTerms.remove('user');
          controller.currentGlossary.termsMapList[term.listIndex] =
              term.toMap();
        }
      }
      //if the exam is not a difficult term exam, then it adds the user to the
      //difficcult term list so it can be then displayed in the difficult term list
      else {
        //loops through every term in the wrongtermlist
        for (var term in controller.wrongTerms) {
          term.usersListDifficultTerms.add('user');
          controller.currentGlossary.termsMapList[term.listIndex] =
              term.toMap();
        }
      }

      controller.currentGlossary.usersInExamList.remove('user');
    });

    controller.isLoading = false;

    return updated;
  }

  //returns a string based on the totalpercentage of the obtained score
  String assing4Score(int totalPercentage) {
    String score4 = 'Z';

    if (totalPercentage < 65) {
      score4 = 'F';
    }
    if (totalPercentage > 64) {
      score4 = 'D';
    }
    if (totalPercentage > 66) {
      score4 = 'D+';
    }
    if (totalPercentage > 69) {
      score4 = 'C-';
    }
    if (totalPercentage > 72) {
      score4 = 'C';
    }
    if (totalPercentage > 76) {
      score4 = 'C+';
    }
    if (totalPercentage > 79) {
      score4 = 'B-';
    }
    if (totalPercentage > 82) {
      score4 = 'B';
    }
    if (totalPercentage > 86) {
      score4 = 'B+';
    }
    if (totalPercentage > 89) {
      score4 = 'A-';
    }
    if (totalPercentage > 92) {
      score4 = 'A';
    }
    if (totalPercentage > 96) {
      score4 = 'A+';
    }
    return score4;
  }

  //returns a string which is a phrase assigned based on the obtained score

  String assignPhrase(int totalPercentage) {
    String phrase = 'Error hehe';
    if (totalPercentage < 65) {
      phrase = 'Gotta study more';
    }
    if (totalPercentage > 64) {
      phrase = 'Not bad';
    }
    if (totalPercentage > 66) {
      phrase = 'Not bad';
    }
    if (totalPercentage > 69) {
      phrase = 'Could be better';
    }
    if (totalPercentage > 72) {
      phrase = 'Could be better';
    }
    if (totalPercentage > 76) {
      phrase = 'Could be better';
    }
    if (totalPercentage > 79) {
      phrase = 'Very good';
    }
    if (totalPercentage > 82) {
      phrase = 'Very good';
    }
    if (totalPercentage > 86) {
      phrase = 'Very good';
    }
    if (totalPercentage > 89) {
      phrase = 'Well done :)';
    }
    if (totalPercentage > 92) {
      phrase = 'Congratulations';
    }
    if (totalPercentage > 96) {
      phrase = 'Amazing';
    }
    if (totalPercentage >= 100) {
      phrase = 'Perfection';
    }
    return phrase;
  }
}
