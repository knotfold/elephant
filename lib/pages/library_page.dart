import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elephant/services/services.dart';
import 'package:elephant/shared/widgets.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textThemeCategories = Theme.of(context).textTheme.headline5;
    final textThemeTitle = Theme.of(context).textTheme.headline2;
    final textThemeSubtitle = Theme.of(context).textTheme.subtitle1;
    return Scaffold(
      appBar: myAppBar(context: context, type: 'libraryPage'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Welcome',
                    style: textThemeTitle,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 15),
                    child: Image(
                      width: 100,
                      height: 100,
                      image: AssetImage('assets/icon1.png'),
                    ),
                  )
                  // const Icon(
                  //   Icons.local_library,
                  //   size: 50,
                  // ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'to the library',
                  style: textThemeSubtitle,
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Row(
                children: [
                  const Icon(Icons.new_releases),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Newest glossaries',
                    style: textThemeCategories,
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('glossaries')
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container();
                  }

                  //if it doesn't have data means that is loading
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.connectionState.name == ' waiting') {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  List<QueryDocumentSnapshot> queryDocuments =
                      snapshot.data!.docs;
                  return Container(
                    height: 150,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queryDocuments.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GlossaryCard(
                            glossary: GlossaryModel.fromDocumentSnapshot(
                              queryDocuments[index],
                            ),
                            route: '/glossaryInfoPage',
                          );
                        }),
                  );
                },
              ),
              const SizedBox(
                height: 45,
              ),
              Row(
                children: [
                  const Icon(Icons.star),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Best rated glossaries',
                    style: textThemeCategories,
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('glossaries')
                    .orderBy('rating', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container();
                  }

                  //if it doesn't have data means that is loading
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.connectionState.name == ' waiting') {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  List<QueryDocumentSnapshot> queryDocuments =
                      snapshot.data!.docs;
                  return Container(
                    height: 150,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queryDocuments.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GlossaryCard(
                            glossary: GlossaryModel.fromDocumentSnapshot(
                              queryDocuments[index],
                            ),
                            route: '/glossaryInfoPage',
                          );
                        }),
                  );
                },
              ),
              const SizedBox(
                height: 45,
              ),
              Row(
                children: [
                  const Icon(Icons.thumb_up_alt_sharp),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Most popular glossaries',
                    style: textThemeCategories,
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('glossaries')
                    .orderBy('dCounter', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container();
                  }

                  //if it doesn't have data means that is loading
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.connectionState.name == ' waiting') {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  List<QueryDocumentSnapshot> queryDocuments =
                      snapshot.data!.docs;
                  return Container(
                    height: 150,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queryDocuments.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GlossaryCard(
                            glossary: GlossaryModel.fromDocumentSnapshot(
                              queryDocuments[index],
                            ),
                            route: '/glossaryInfoPage',
                          );
                        }),
                  );
                },
              ),
              const SizedBox(
                height: 45,
              ),
              Row(
                children: [
                  const Icon(Icons.translate),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Language glossaries',
                    style: textThemeCategories,
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('glossaries')
                    .where('mainCategory', isEqualTo: 'MainCategory.language')
                    .orderBy('creationDate', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container();
                  }

                  //if it doesn't have data means that is loading
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.connectionState.name == ' waiting') {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  List<QueryDocumentSnapshot> queryDocuments =
                      snapshot.data!.docs;
                  return Container(
                    height: 150,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queryDocuments.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GlossaryCard(
                            glossary: GlossaryModel.fromDocumentSnapshot(
                              queryDocuments[index],
                            ),
                            route: '/glossaryInfoPage',
                          );
                        }),
                  );
                },
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                children: [
                  const Icon(Icons.science),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Science glossaries',
                    style: textThemeCategories,
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('glossaries')
                    .where('mainCategory', isEqualTo: 'MainCategory.science')
                    .orderBy('creationDate', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Container();
                  }

                  //if it doesn't have data means that is loading
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.connectionState.name == ' waiting') {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  List<QueryDocumentSnapshot> queryDocuments =
                      snapshot.data!.docs;
                  return queryDocuments.isEmpty
                      ? const Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text('There is no science glossaries'),
                        )
                      : SizedBox(
                          height: 150,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: queryDocuments.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GlossaryCard(
                                  glossary: GlossaryModel.fromDocumentSnapshot(
                                    queryDocuments[index],
                                  ),
                                  route: '/glossaryInfoPage',
                                );
                              }),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
