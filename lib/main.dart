import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart'; // IntroScreen 위젯이 정의된 파일을 import 해야 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool introShown = prefs.getBool('introShown') ?? false;

  runApp(MyApp(introShown: introShown));
}

class MyApp extends StatelessWidget {
  final bool introShown;

  const MyApp({required this.introShown, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => const HomeScreen(),
        // ... 다른 라우트 정의
      },
      title: 'Question App',
      home: introShown ? const HomeScreen() : const IntroScreen(),
    );
  }
}
