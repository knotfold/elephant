import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/pages/pages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

AppBar myAppBar(
    {String? title, required BuildContext context, required String type}) {
  Controller controller = Provider.of<Controller>(context);
  return AppBar(
    leading: type == 'home'
        ? const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Image(
              image: AssetImage('assets/icon1.png'),
            ),
          )
        : null,
    title: Text(title ?? 'Elephant'),
    actions: [
      type == 'home'
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settingsPage');
              },
              icon: const Icon(Icons.settings_applications_outlined))
          : Container(),
      type == 'glossary'
          ? IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
              icon: const Icon(Icons.search))
          : Container(),
      type == 'glossary'
          ? IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => const DialogStartButton());
              },
              icon: const Icon(Icons.play_circle_outline_rounded))
          : Container(),
      type == 'glossary'
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/filterGlossaryTermsPage');
              },
              icon: const Icon(Icons.filter_list))
          : Container(),
      type == 'Difficult Terms'
          ? IconButton(
              onPressed: () {
                navigateToDifficultExam('difficultExam', context, controller);
              },
              icon: const Icon(Icons.play_circle_outline_outlined))
          : Container(),
      IconButton(
          onPressed: () {}, icon: const Icon(Icons.help_outline_rounded)),
    ],
  );
}

navigateToDifficultExam(
  String type,
  BuildContext context,
  Controller controller,
) {
  controller.clearLists();
  controller.generateCurrentTermsList();
  controller.generateDifficultTermList();
  Navigator.of(context).pop();
  Navigator.of(context).pushNamed(ExamPage.routeName,
      arguments: ExamArguments(
        examType: type,
      ));
}

class CheckBoxListTags extends StatelessWidget {
  const CheckBoxListTags({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.currentGlossary.tags.length,
        itemBuilder: (context, index) {
          String tag = controller.currentGlossary.tags[index];
          return CheckboxListTile(
              title: Text(tag),
              value: controller.checkTagSelected(tag),
              onChanged: (bool? value) {
                if (!value!) {
                  controller.selectedTags.remove(tag);
                } else {
                  controller.selectedTags.add(tag);
                }

                controller.notifyNoob();
              });
        });
  }
}

class GlossaryCard extends StatelessWidget {
  final GlossaryModel glossary;
  const GlossaryCard({
    Key? key,
    required this.glossary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        controller.clearLists();
        controller.currentGlossary = glossary;
        Navigator.of(context).pushNamed('/glossaryPage');
      },
      child: Card(
        elevation: 5,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.book,
                size: 30,
              ),
              const SizedBox(
                height: 35,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: secondaryColor,
                ),
                child: Text(
                  glossary.name,
                ),
              ),

              // const Icon(
              //   Icons.menu_book,
              //   size: 0,
              //   color: pDark,
              // )
              // const Image(
              //   fit: BoxFit.fitHeight,
              //   image: AssetImage('assets/elebaby.png'),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
