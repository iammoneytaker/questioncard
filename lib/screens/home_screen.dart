import 'package:flutter/material.dart';
import 'package:questioncard/screens/questioncard/questioncard_screen.dart';
import 'package:questioncard/screens/setting_screen.dart';

import '../widgets/bottompage.dart';
import 'liargame/liargame_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xffF5988D);
  final Color backgroundColor = const Color(0xfffffff0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          '어색할 때',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'HamChorong',
          ),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              openPageFromBottom(context, const SettingScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            _buildCategoryCard(
              title: '질문 카드',
              imagePath: 'assets/images/questionlogo.png',
              color: Colors.blue,
              onTap: () {
                // 질문 카드 화면으로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QuestionCardScreen(),
                ));
              },
            ),
            _buildCategoryCard(
              title: '라이어게임',
              imagePath: 'assets/images/liargame.png',
              color: Colors.green,
              onTap: () {
                // 게임 선택 화면으로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LiarGameScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    // 화면의 너비에 따라 이미지 크기를 결정
    double screenWidth = MediaQuery.of(context).size.width;
    double cardHeight = screenWidth / 2 * 0.8; // 카드의 높이를 화면 너비의 절반의 80%로 설정
    double imageHeight = cardHeight * 0.6; // 이미지 높이를 카드 높이의 60%로 설정

    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: imageHeight, // 동적으로 계산된 이미지 높이
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'HamChorong',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
