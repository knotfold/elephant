import 'package:elephant/services/services.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:provider/provider.dart';

class ExamResultArguments {
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
    final args =
        ModalRoute.of(context)!.settings.arguments as ExamResultArguments;
    Controller controller = Provider.of<Controller>(context);
    List<TermModel> rightTermsList = controller.rightTerms;
    List<TermModel> wrongTermsList = controller.wrongTerms;
    int rightAnswers = rightTermsList.length;
    int wrongAnswers = wrongTermsList.length;
    int total = args.difficultTerms
        ? controller.difficultTermList.length
        : controller.currentTermList.length;
    int totalPercentage = (rightAnswers / total * 100).round();
    final textStyle1 = Theme.of(context).textTheme.headline6;
    final textStyleFinalScore = Theme.of(context).textTheme.headline6;
    final textStylescore4Scale = Theme.of(context).textTheme.headline1;
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        controller.clearLists();
        controller.generateCurrentTermsList();
        controller.generateDifficultTermList();
        return true;
      },
      child: Scaffold(
        appBar: myAppBar(context: context, type: 'Exam Results'),
        body: FutureBuilder<bool>(
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

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Score: $rightAnswers/$total',
                        style: textStyleFinalScore,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CircleAvatar(
                        foregroundColor: secondaryColor,
                        backgroundColor: secondaryColor,
                        maxRadius: 80,
                        child: Text(
                          assing4Score(totalPercentage),
                          style: textStylescore4Scale,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        assignPhrase(totalPercentage),
                        style: textStylescore4Scale,
                      ),
                      const SizedBox(
                        height: 100,
                      ),
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
                          }),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<bool> updateDifficultTerms(
      Controller controller, bool difficultTerms) async {
    bool updated = true;
    if (difficultTerms) {
      for (var term in controller.rightTerms) {
        await term.reference
            .update({'difficultTerm': false}).onError((error, stackTrace) {
          updated = false;
          print(error);
        });
      }
      print('Difficult terms updated');
    } else {
      for (var term in controller.wrongTerms) {
        await term.reference
            .update({'difficultTerm': true}).onError((error, stackTrace) {
          updated = false;
          print(error);
        });
      }
      print('Difficult terms updated');
    }

    return updated;
  }

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
      phrase = 'Amazing';
    }
    if (totalPercentage > 92) {
      phrase = 'Amazing';
    }
    if (totalPercentage > 96) {
      phrase = 'Perfect';
    }
    return phrase;
  }
}
