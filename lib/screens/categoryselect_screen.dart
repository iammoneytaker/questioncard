import 'package:flutter/material.dart';
import 'package:questioncard/screens/question_screen.dart';

import '../data/category_data.dart';

class CategorySelectScreen extends StatelessWidget {
  const CategorySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 한 줄에 2개의 카드
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 카테고리 이름
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      categories[index].name,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  // 해시태그들
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
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
