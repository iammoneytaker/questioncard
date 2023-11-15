import 'package:flutter/material.dart';
import 'package:questioncard/screens/celebrityquiz/zoomin_screen.dart';
import 'package:questioncard/screens/celebrityquiz/zoomout_screen.dart';
import '../../data/celebrityquiz_data.dart';

class GameCategoryScreen extends StatefulWidget {
  final GameCategory gameUnit; // zoomin, zoomout, spped
  const GameCategoryScreen({super.key, required this.gameUnit});

  @override
  State<GameCategoryScreen> createState() => _GameCategoryScreenState();
}

class _GameCategoryScreenState extends State<GameCategoryScreen> {
  final Color primaryColor = const Color(0xffF5988D);
  final Color backgroundColor = const Color(0xfffffff0);

  String? selectCategory;

  _onTap(String category) {
    setState(() {
      selectCategory = category; // Update the state with the selected category
    });

    switch (widget.gameUnit) {
      case GameCategory.zoomin:
        return Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ZoomInScreen(
            category: selectCategory!,
          ),
        ));
      case GameCategory.zoomout:
        return Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ZoomOutScreen(category: selectCategory!),
        ));
      case GameCategory.speed:
        return Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ZoomOutScreen(category: selectCategory!),
        ));
      default:
        return Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ZoomOutScreen(category: selectCategory!),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          '인물유형선택',
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
              title: '아이돌',
              imagePath: 'assets/images/exo.png',
              color: Colors.green,
              onTap: () {
                _onTap('idol');
              },
              hashTags: ['미모', '꿀잼', '아이돌'],
            ),
            _buildCategoryCard(
              title: '배우',
              imagePath: 'assets/images/actorimage.jpeg',
              color: Colors.green,
              onTap: () {
                _onTap('actor');
              },
              hashTags: ['분위기', '장난아님', '멋짐'],
            ),
            _buildCategoryCard(
              title: '코미디언',
              imagePath: 'assets/images/psick.png',
              color: Colors.blue,
              onTap: () {
                _onTap('comedian');
              },
              hashTags: ['웃김', '그냥웃김', '행복'],
            ),
            _buildCategoryCard(
              title: '랜덤',
              imagePath: 'assets/images/speedquiz.png',
              color: Colors.blue,
              onTap: () {
                _onTap('random');
              },
              hashTags: ['아무거나', '아이돌', '배우', '코미디언'],
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
