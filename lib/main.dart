import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:elephant/pages/difficult_terms.dart';
import 'package:elephant/pages/exam_results.dart';
import 'package:elephant/pages/pages.dart';
import 'package:elephant/pages/theme_chooser_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';

//the main is where eeverything in the app starts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //this is important cause it initializes the firebase app, since it is the database it is crucial for this to be executed
  FirebaseApp app = await Firebase.initializeApp();
  runApp(
    /*the multi provider widget is very important too cause it is the thing that let us use variables in our app in different
    instances of the app */
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Controller()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      //eliminates the debugchecked banner which is very important
      debugShowCheckedModeBanner: false,
      title: 'Elephant',
      /*sets the theme of the app, both light and dark, and since we are already using the controller
      this values can be changed to choose differen themes*/
      theme: controller.light,
      darkTheme: controller.dark,
      /*the theme mode choose wheter is dark or light, right now it is set to the system preferences, later we could give 
      the user the option to choose whatever they like*/
      themeMode: ThemeMode.system,
      //this is the home of the app and can be easily navigated to with the / sign
      home: const Home(),
      /*this is where the app starts and it is set to start in the app start page to load the user info data and shows a cool intro of the app*/
      initialRoute: '/startPage',
      //this are all the routes to where we can navigate in the app
      routes: {
        ExamPage.routeName: (context) => const ExamPage(),
        ExamResultPage.routeName: (context) => const ExamResultPage(),
        '/glossaryPage': (context) => const GlossaryPage(),
        '/difficultTermsPage': (context) => const DifficultTermsPage(),
        '/filterGlossaryTermsPage': (context) =>
            const FilterGlossaryTermsPage(),
        '/settingsPage': (context) => const SettingsPage(),
        '/themeChooserPage': (context) => const ThemeChooserPage(),
        '/startPage': (context) => const StartPage(),
        '/widgetTester': (context) => const WidgetTester(),
        '/examSettingsPage': (context) => const ExamSettingsPage(),
      },
    );
  }
}
