import 'package:flutter/material.dart';
import 'package:questioncard/screens/celebrityquiz/celebrityquiz_category_screen.dart';
import 'package:questioncard/screens/questioncard/questioncard_screen.dart';
import 'package:questioncard/screens/setting_screen.dart';
import 'package:questioncard/screens/knowledge/difficulty_selection_screen.dart';

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
          childAspectRatio: 0.7, // 카드의 가로/세로 비율
          crossAxisSpacing: 10, // 카드 간의 가로 간격
          mainAxisSpacing: 10, // 카드 간의 세로 간격
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
              hashTags: ['연인', '남/여사친', '꿀잼', '아이스브레이킹'],
            ),
            _buildCategoryCard(
              title: '라이어게임',
              imagePath: 'assets/images/liargame.png',
              color: Colors.green,
              onTap: () {
                // 게임 선택 화면으로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LiarGameScreen(),
                ));
              },
              hashTags: ['심리', '모임용게임', '친해지기', '꿀잼'],
            ),
            _buildCategoryCard(
              title: '인물퀴즈',
              imagePath: 'assets/images/personquiz.png',
              color: Colors.green,
              onTap: () {
                // 게임 선택 화면으로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CelebrityCategoryScreen(),
                ));
              },
              hashTags: ['줌인', '줌아웃', '경쟁', '순발력'],
            ),
            _buildCategoryCard(
              title: '상식퀴즈',
              imagePath: 'assets/images/knowledge.png',
              color: Colors.orange,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DifficultySelectionScreen(),
                ));
              },
              hashTags: ['상식', '퀴즈', '재미', '학습'],
              isComplete: true,
              isNew: true,
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
    required List<String> hashTags,
    bool isComplete = true,
    bool isNew = false,
  }) {
    // 화면의 너비에 따라 이미지 크기를 결정
    double screenWidth = MediaQuery.of(context).size.width;
    double cardHeight = screenWidth / 2 * 0.8; // 카드의 높이를 화면 너비의 절반의 80%로 설정
    double imageHeight = cardHeight * 0.6; // 이미지 높이를 카드 높이의 60%로 설정

    // 아이패드 또는 큰 화면에서는 더 큰 글씨 크기를 사용
    double tagFontSize = screenWidth > 600 ? 18.0 : 12.0;

    return Card(
      elevation: 8.0,
      color: isComplete ? Colors.white : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: <Widget>[
            Center(
              child: SizedBox(
                height: imageHeight, // 동적으로 계산된 이미지 높이
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              left: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isNew)
              const Positioned(
                top: 8.0,
                right: 8.0,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'NEW!!',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8.0,
              right: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: hashTags
                    .map((tag) => Text(
                          '#$tag',
                          style: TextStyle(
                            color: const Color(0xffF5988D),
                            fontSize: tagFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
