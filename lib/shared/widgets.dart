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
    title: Text(title ?? 'Elephant'),
    actions: [
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
                showDialog(
                    context: context,
                    builder: (context) {
                      return const FilterListDialog();
                    });
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
  Navigator.of(context).pushNamed(ExamPage.routeName,
      arguments: ExamArguments(
        examType: type,
      ));
}

class FilterListDialog extends StatefulWidget {
  const FilterListDialog({Key? key}) : super(key: key);

  @override
  State<FilterListDialog> createState() => _FilterListDialogState();
}

class _FilterListDialogState extends State<FilterListDialog> {
  final formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  late String tagName;

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = Theme.of(context).textTheme.headline6;
    final subtitleTextStyle = Theme.of(context).textTheme.subtitle1;
    Controller controller =
        Provider.of<Controller>(context); // TODO: implement build
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // titleTextStyle: titleTextStyle,
          children: [
            Text(
              'Filter glossary',
              style: titleTextStyle,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Tags:',
              style: subtitleTextStyle,
            ),
            controller.currentGlossary.tags.isEmpty
                ? const Text(
                    'Currently your glossary does not contain any tags, start by adding a tag on the button below')
                : ChecBoxListTags(controller: controller),
            ButtonBar(
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            titlePadding: const EdgeInsets.all(20),
                            title: const Text('Add a new tag'),
                            contentPadding: const EdgeInsets.all(15),
                            children: [
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        label: Text('Tag name'),
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please add a name to the tag';
                                        }
                                      },
                                      onSaved: (value) {
                                        tagName = value!;
                                      },
                                      controller: textEditingController,
                                    ),
                                    ButtonBar(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (!formKey.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            formKey.currentState!.save();
                                            await controller.currentGlossary
                                                .documentReference
                                                .update({
                                              'tags': FieldValue.arrayUnion(
                                                  [tagName])
                                            }).then((value) {
                                              Navigator.of(context).pop();
                                              //Display query succeded
                                              Fluttertoast.showToast(
                                                  msg: 'Tag succesfully added',
                                                  toastLength:
                                                      Toast.LENGTH_LONG);
                                              //At the tag to the momentary state of the current glossary
                                              controller.currentGlossary.tags
                                                  .add(tagName);
                                              controller.notifyNoob();
                                            });
                                          },
                                          child: const Text('New Tag'),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        });
                  },
                  child: const Text('Add new tag',
                      style: TextStyle(color: secondaryColor)),
                ),
                ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      'Filter tags',
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChecBoxListTags extends StatelessWidget {
  const ChecBoxListTags({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
