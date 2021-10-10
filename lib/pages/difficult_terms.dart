import 'package:elephant/services/services.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/controller.dart';
import 'package:provider/provider.dart';

class DifficultTermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleHeadline = Theme.of(context).textTheme.headline5;
    // TODO: implement build
    return Scaffold(
      appBar: myAppBar(context: context, type: 'Difficult Terms'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Difficult Terms',
              style: textStyleHeadline,
            ),
            controller.difficultTermList.isEmpty
                ? const Text(
                    'You do not have difficult terms at this moment. Difficult terms are generated every time you make a mistake in a exam and they help you to reinforce your knowledge')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.difficultTermList.length,
                    itemBuilder: (context, index) {
                      TermModel term = controller.difficultTermList[index];
                      return ListTile(
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [],
                        ),
                        leading: Icon(controller.termIconAsignner(term.type)),
                        title: Text(term.term),
                        subtitle: Text(term.answer),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}