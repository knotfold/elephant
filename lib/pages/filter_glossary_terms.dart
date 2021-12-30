import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:elephant/services/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:elephant/shared/shared.dart';

//this class displays a pag that is in charge of displaying the different filters
//that can be applied to the list of terms displayed inside the glossary page view
//this page allows to filter the terms by their tags, favorite or not favorites
// and also chooseto order them by their index number or alphabetically
class FilterGlossaryTermsPage extends StatefulWidget {
  const FilterGlossaryTermsPage({Key? key}) : super(key: key);

  @override
  State<FilterGlossaryTermsPage> createState() =>
      _FilterGlossaryTermsPageState();
}

class _FilterGlossaryTermsPageState extends State<FilterGlossaryTermsPage> {
  //form key used for the add new tag dialog
  final formKey = GlobalKey<FormState>();
  //text editing controller of the add tag dialog text input
  TextEditingController textEditingController = TextEditingController();
  //recieves the tag name to add it to the database
  late String tagName;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    //text style used for the subtitles
    final subtitleTextStyle = Theme.of(context).textTheme.subtitle1;
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      appBar: myAppBar(
          context: context,
          title: 'Filter Glossary Terms',
          type: 'filterTermsPage'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //row used to display the options to sort the list by add order or
              //alpahbetically
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Expanded(
                      child: Text('Select how to format the list order:')),
                  Icon(Icons.format_list_numbered,
                      color: controller.orderAlphabetically
                          ? colorScheme.onBackground
                          : Colors.grey),
                  Switch(
                      value: controller.orderAlphabetically,
                      onChanged: (value) {
                        controller.orderAlphabetically = value;
                        Fluttertoast.showToast(
                            msg:
                                'Changed to ${controller.orderAlphabetically ? 'alphabetical order' : 'numerical order'}');
                        controller.notifyNoob();
                      }),
                  Icon(
                    Icons.sort_by_alpha,
                    color: !controller.orderAlphabetically
                        ? colorScheme.onBackground
                        : Colors.grey,
                  ),
                ],
              ),
              //button bar for the add tag button and the use favorites button
              ButtonBar(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      //if the glossary already has 20 tags it doesnt allow the user to add more tags
                      if (controller.currentGlossary.tags.length >= 20) {
                        Fluttertoast.showToast(
                            toastLength: Toast.LENGTH_LONG,
                            msg: 'Maximum number of tags reached');
                        return;
                      }
                      //dialog that lets the user add a new tag
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
                                        maxLength: 20,
                                        decoration: const InputDecoration(
                                          label: Text('Tag name'),
                                        ),
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Please add a name to the tag';
                                          }
                                          if (controller.currentGlossary.tags
                                              .contains(value.trim())) {
                                            return 'This tag already exists';
                                          }
                                        },
                                        onSaved: (value) {
                                          tagName = value!;
                                        },
                                        controller: textEditingController,
                                      ),
                                      ButtonBar(
                                        children: [
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              bool hasError = false;
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
                                              }).onError((error, stackTrace) {
                                                hasError = true;
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Error, tag could not be added',
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                              }).then((value) {
                                                if (!hasError) {
                                                  Navigator.of(context).pop();
                                                  //Display query succeded
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Tag succesfully added',
                                                      toastLength:
                                                          Toast.LENGTH_LONG);
                                                  //At the tag to the momentary state of the current glossary

                                                  controller
                                                      .currentGlossary.tags
                                                      .add(tagName);
                                                  controller.notifyNoob();
                                                }
                                              }).timeout(
                                                const Duration(seconds: 30),
                                                onTimeout: () {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Error adding the add, check your connection',
                                                      toastLength:
                                                          Toast.LENGTH_LONG);
                                                },
                                              );
                                            },
                                            child: const Text('Add Tag'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          });
                    },
                    child: const Text(
                      'Add new tag',
                    ),
                  ),
                  const SizedBox(
                    width: 2,
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
                    ),
                  ),
                  Icon(
                    controller.useFavoriteTerms
                        ? Icons.star
                        : Icons.star_border,
                    color: controller.useFavoriteTerms
                        ? Colors.amber
                        : Theme.of(context).colorScheme.onBackground,
                  )
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
