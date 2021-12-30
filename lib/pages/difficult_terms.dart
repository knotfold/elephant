import 'package:elephant/services/services.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//This is a page in charge of displaying the difficult terms.

class DifficultTermsPage extends StatefulWidget {
  const DifficultTermsPage({Key? key}) : super(key: key);

  @override
  State<DifficultTermsPage> createState() => _DifficultTermsPageState();
}

class _DifficultTermsPageState extends State<DifficultTermsPage> {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    //Text style used to display the title of the page
    final textStyleHeadline = Theme.of(context).textTheme.headline5;
    return Scaffold(
      //Appbar of the app
      appBar: myAppBar(
          context: context, type: 'Difficult Terms', title: 'Difficult terms'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Difficult Terms',
                style: textStyleHeadline,
              ),
              //The comparison checks if the list is empty if it is, it displays a Text letting know the user that there is
              //no difficult terms, if it is not empty it show a list of the difficult terms.
              controller.difficultTermList.isEmpty
                  ? const Text(
                      'You do not have difficult terms at this moment. Difficult terms are generated every time you make a mistake in a exam and they help you to reinforce your knowledge')
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.difficultTermList.length,
                      itemBuilder: (context, index) {
                        TermModel term = controller.difficultTermList[index];
                        return ListTileTerm(term: term, controller: controller);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
