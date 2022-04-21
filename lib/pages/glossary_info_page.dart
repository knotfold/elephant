import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GlossaryInfoPage extends StatefulWidget {
  const GlossaryInfoPage({Key? key}) : super(key: key);

  @override
  State<GlossaryInfoPage> createState() => _GlossaryInfoPageState();
}

class _GlossaryInfoPageState extends State<GlossaryInfoPage> {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      appBar: myAppBar(context: context, type: 'glossary info'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              GlossaryInfo(glossaryModel: controller.currentGlossary),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  GlossaryModel newGlossary = controller.currentGlossary;
                  newGlossary.creator = controller.activeUser.username;
                  newGlossary.dCounter = 0;
                  newGlossary.name = newGlossary.name + '(Copy)';
                  newGlossary.nameSearch =
                      newGlossary.name.toLowerCase().trim();
                  newGlossary.creationDate = Timestamp.fromDate(DateTime.now());
                  newGlossary.userRatings = [];
                  newGlossary.lastChecked = Timestamp.fromDate(DateTime.now());
                  newGlossary.glossaryUsers = [controller.activeUser.username];
                  newGlossary.usersInExamList = [];
                  newGlossary.origin = controller.currentGlossary.id;
                  controller.isLoading = true;
                  await FirebaseFirestore.instance
                      .collection('glossaries')
                      .add(newGlossary.toMap())
                      .catchError((onError) {
                        controller.isLoading = false;
                        setState(() {});
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg:
                                'Error cloning the glossary, check your connection',
                            toastLength: Toast.LENGTH_LONG);
                      })
                      // ignore: avoid_print
                      .then((value) => print('Glossary cloned'))
                      .timeout(
                        const Duration(seconds: 30),
                        onTimeout: () {
                          controller.isLoading = false;
                          setState(() {});
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                              msg:
                                  'Error cloning the glossary, check your internet connection',
                              toastLength: Toast.LENGTH_LONG);
                        },
                      );
                  await controller.currentGlossaryTransaction(() {
                    controller.currentGlossary.dCounter =
                        controller.currentGlossary.dCounter++;
                  });
                  setState(() {
                    controller.isLoading = false;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.copy_all),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Clone glossary to my library',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Text('This glossary has been cloned ' +
                  controller.currentGlossary.dCounter.toString() +
                  ' times'),
              const SizedBox(
                height: 30,
              ),
              ListViewBuilderTermsExample()
            ],
          ),
        ),
      ),
    );
  }
}

class ListViewBuilderTermsExample extends StatelessWidget {
  ListViewBuilderTermsExample({
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    final textStyleHeadline = Theme.of(context).textTheme.headline5;

    List<TermModel> termsList = controller.listAssignerFunction();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: Container(),
            title: Text(
              'Terms ${termsList.length}',
              textAlign: TextAlign.start,
              style: textStyleHeadline,
            ),
          ),
          //instead of a listview builder a special customscrolliview with a sliverlist is used
          //seems to be working pretty pretty good
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                TermModel term = termsList[index];
                if (index > termsList.length) return null;
                return ListTileTermDisplayExample(
                    term: term, controller: controller);
              },
              childCount: termsList.length > 50 ? 50 : termsList.length,
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileTermDisplayExample extends StatelessWidget {
  const ListTileTermDisplayExample({
    Key? key,
    required this.term,
    required this.controller,
  }) : super(key: key);

  //recieves the term to be displayed as its constructor
  final TermModel term;
  final Controller controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //idk what is the visual denstity for, i think it makes the tile more wide
      visualDensity: const VisualDensity(horizontal: -4),
      //content padding lol
      contentPadding: const EdgeInsets.all(2),

      /*the leading can show 2 options based on the sorting order chosen by the user*/
      leading: Text(
        controller.orderAlphabetically
            ? term.term.characters.first
            : (term.listIndex + 1).toString(),
      ),
      title: Text(term.term),
      subtitle: Text(term.answer),
    );
  }
}
