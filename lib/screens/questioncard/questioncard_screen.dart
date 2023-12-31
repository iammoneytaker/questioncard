import 'package:flutter/material.dart';

import 'bookmark_screen.dart';
import 'categoryselect_screen.dart';
import '../setting_screen.dart';

class QuestionCardScreen extends StatefulWidget {
  const QuestionCardScreen({super.key});

  @override
  State<QuestionCardScreen> createState() => _QuestionCardScreenState();
}

class _QuestionCardScreenState extends State<QuestionCardScreen> {
  final Color primaryColor = const Color(0xffF5988D);
  final Color backgroundColor = const Color(0xfffffff0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {
              _openPageFromBottom(context, const BookMarkScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _openPageFromBottom(context, const SettingScreen());
            },
          ),
        ],
      ),
      body: const CategorySelectScreen(),
    );
  }

  void _openPageFromBottom(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            backgroundColor: const Color(0xff429FBF),
          ),
          body: page,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}
