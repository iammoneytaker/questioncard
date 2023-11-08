import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:questioncard/providers/gamesetting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart'; // IntroScreen 위젯이 정의된 파일을 import 해야 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool introShown = prefs.getBool('introShown') ?? false;

  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameSettings(),
      child: MyApp(introShown: introShown),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool introShown;

  const MyApp({required this.introShown, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        // ... 다른 라우트 정의
      },
      title: 'Question App',
      home: introShown ? const HomeScreen() : const IntroScreen(),
    );
  }
}
