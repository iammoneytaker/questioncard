import 'package:flutter/material.dart';
import 'package:questioncard/screens/questioncard/question_screen.dart';

import '../../data/category_data.dart';

class CategorySelectScreen extends StatelessWidget {
  const CategorySelectScreen({super.key});

  IconData getIconForCategory(String categoryName) {
    switch (categoryName) {
      case '연애':
        return Icons.favorite;
      case '일상':
        return Icons.wb_sunny;
      case '친구':
        return Icons.group;
      case '대학생':
        return Icons.school;
      case '진로':
        return Icons.work;
      case '인생':
        return Icons.accessibility_new;
      case '밸런스게임':
        return Icons.gamepad;
      default:
        return Icons.category; // 기본 아이콘
    }
  }

  Color getIconColorForCategory(String categoryName) {
    switch (categoryName) {
      case '연애':
        return Colors.red;
      case '일상':
        return Colors.yellow.shade600;
      case '친구':
        return const Color(0xff4FBEE5);
      case '대학생':
        return const Color(0xffA799F8);
      case '진로':
        return const Color(0xff303030);
      case '인생':
        return const Color(0xff18413E);
      case '밸런스게임':
        return Colors.red;
      default:
        return Colors.black; // 기본 아이콘
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 방향을 확인합니다.
    Orientation orientation = MediaQuery.of(context).orientation;
    // 화면의 너비를 확인합니다.
    double width = MediaQuery.of(context).size.width;

    // 화면의 방향과 너비에 따라 crossAxisCount 값을 결정합니다.
    int crossAxisCount = 2; // 기본값
    if (orientation == Orientation.landscape || width > 600) {
      // 가로 모드이거나 화면 너비가 600픽셀보다 큰 경우
      crossAxisCount = 3;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // 한 줄에 2~3개의 카드
          childAspectRatio: 0.7, // 카드의 가로/세로 비율
          crossAxisSpacing: 10, // 카드 간의 가로 간격
          mainAxisSpacing: 10, // 카드 간의 세로 간격
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // borderRadius 수정
            ),
            elevation: 5.0, // 그림자 효과 강화
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        QuestionScreen(
                      categoryCode: categories[index].categoryCode,
                      categoryName: categories[index].name,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
              child: Stack(
                children: [
                  // 카테고리 이름 (맨 위)
                  Positioned(
                    top: 16.0,
                    left: 16.0,
                    child: Text(
                      categories[index].name,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // 아이콘 (정 중앙)
                  Center(
                    child: Icon(
                      getIconForCategory(categories[index].name),
                      size: 50.0,
                      color: getIconColorForCategory(
                          categories[index].name), // 아이콘 색상도 다르게 설정
                    ),
                  ),
                  // 해시태그들 (맨 아래)
                  Positioned(
                    bottom: 8.0,
                    right: 8.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: categories[index]
                          .hashTags
                          .map((tag) => Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Color(0xffF5988D),
                                  fontSize: 12.0,
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
        },
      ),
    );
  }
}
