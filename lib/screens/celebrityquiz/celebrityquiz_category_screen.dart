import 'package:flutter/material.dart';
import 'package:questioncard/data/celebrityquiz_data.dart';
import 'package:questioncard/screens/celebrityquiz/gamecategory_screen.dart';

class CelebrityCategoryScreen extends StatefulWidget {
  const CelebrityCategoryScreen({super.key});

  @override
  State<CelebrityCategoryScreen> createState() =>
      _CelebrityCategoryScreenState();
}

class _CelebrityCategoryScreenState extends State<CelebrityCategoryScreen> {
  final Color primaryColor = const Color(0xffF5988D);

  final Color backgroundColor = const Color(0xfffffff0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          '게임유형선택',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'HamChorong',
          ),
        ),
        backgroundColor: primaryColor,
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
              title: '줌인 GAME',
              imagePath: 'assets/images/zoomout.png',
              color: Colors.green,
              onTap: () {
                // 줌인게임 화면으로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GameCategoryScreen(
                    gameUnit: GameCategory.zoomin,
                  ),
                ));
              },
              hashTags: ['ZOOM-IN', '시력', '연예인'],
            ),
            _buildCategoryCard(
              title: '줌아웃 GAME',
              imagePath: 'assets/images/zoomout.png',
              color: Colors.green,
              onTap: () {
                // 게임 선택 화면으로 이동
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GameCategoryScreen(
                    gameUnit: GameCategory.zoomout,
                  ),
                ));
              },
              hashTags: ['ZOOM-OUT', '재치', '연예인'],
            ),
            _buildCategoryCard(
              title: '스피드 인물 퀴즈',
              imagePath: 'assets/images/speedquiz.png',
              color: Colors.blue,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GameCategoryScreen(
                    gameUnit: GameCategory.speed,
                  ),
                ));
              },
              hashTags: ['순발력', '아이돌', '배우', '코미디언'],
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
