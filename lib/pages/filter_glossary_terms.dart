import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:elephant/shared/shared.dart';

class FilterGlossaryTermsPage extends StatefulWidget {
  const FilterGlossaryTermsPage({Key? key}) : super(key: key);

  @override
  State<FilterGlossaryTermsPage> createState() =>
      _FilterGlossaryTermsPageState();
}

class _FilterGlossaryTermsPageState extends State<FilterGlossaryTermsPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  late String tagName;

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = Theme.of(context).textTheme.headline6;
    final subtitleTextStyle = Theme.of(context).textTheme.subtitle1;
    Controller controller =
        Provider.of<Controller>(context); // TODO: implement build
    return Scaffold(
      appBar: myAppBar(
          context: context, title: 'Filter Glossary Terms', type: 'lol'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            // titleTextStyle: titleTextStyle,
            children: [
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
                                                    msg:
                                                        'Tag succesfully added',
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
                      onPressed: () {
                        controller.useFavoriteTerms =
                            controller.useFavoriteTerms ? false : true;
                        controller.notifyNoob();
                      },
                      child: Text(
                        controller.useFavoriteTerms
                            ? 'Not Favorites'
                            : 'Use favorites',
                      ))
                ],
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
                  : CheckBoxListTags(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
