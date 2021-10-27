import 'package:elephant/pages/difficult_terms.dart';
import 'package:elephant/pages/exam.dart';
import 'package:elephant/pages/exam_results.dart';
import 'package:elephant/pages/pages.dart';
import 'package:elephant/pages/theme_chooser_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'themes/app_main_theme.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  runApp(
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: GalleryThemeData.lightThemeData,
      darkTheme: GalleryThemeData.darkThemeData,
      themeMode: ThemeMode.system,
      home: const Home(),
      routes: {
        ExamPage.routeName: (context) => const ExamPage(),
        ExamResultPage.routeName: (context) => const ExamResultPage(),
        '/glossaryPage': (context) => const GlossaryPage(),
        '/difficultTermsPage': (context) => const DifficultTermsPage(),
        '/filterGlossaryTermsPage': (context) =>
            const FilterGlossaryTermsPage(),
        '/settingsPage': (context) => const SettingsPage(),
        '/themeChooserPage': (context) => const ThemeChooserPage(),
      },
    );
  }
}
