import 'package:elephant/services/services.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/shared/shared.dart';
import 'package:provider/provider.dart';

class ExamResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    List<TermModel> rightTermsList = controller.rightTerms;
    List<TermModel> wrongTermsList = controller.wrongTerms;
    int rightAnswers = rightTermsList.length;
    int wrongAnswers = wrongTermsList.length;
    int total = controller.currentTermList.length;
    int totalPercentage = (rightAnswers / total * 100).round();
    final textStyle1 = Theme.of(context).textTheme.headline6;
    final textStyleFinalScore = Theme.of(context).textTheme.headline6;
    final textStylescore4Scale = Theme.of(context).textTheme.headline1;
    // TODO: implement build
    return Scaffold(
      appBar: myAppBar(context: context, type: 'Exam Results'),
      body: Padding(
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
                foregroundColor: pLight,
                backgroundColor: pLight,
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
                  const Icon(Icons.check_circle_outlined),
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
                  shrinkWrap: true,
                  itemCount: wrongTermsList.length,
                  itemBuilder: (context, index) {
                    TermModel term = wrongTermsList[index];
                    return ListTile(
                      leading: Icon(controller.termIconAsignner(term.type)),
                      title: Text(term.term),
                      subtitle: Text(term.answer),
                    );
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outlined),
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
                  shrinkWrap: true,
                  itemCount: rightTermsList.length,
                  itemBuilder: (context, index) {
                    TermModel term = rightTermsList[index];
                    return ListTile(
                      leading: Icon(controller.termIconAsignner(term.type)),
                      title: Text(term.term),
                      subtitle: Text(term.answer),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  String assing4Score(int totalPercentage) {
    String score4 = 'Z';

    print(totalPercentage);

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
      phrase = 'Amazing';
    }
    return phrase;
  }
}
