import 'package:flutter/material.dart';
import 'package:questioncard/screens/question_screen.dart';
import '../models/category.dart';

class HomeScreen extends StatelessWidget {
  final List<Category> categories = [
    Category(
        categoryCode: "00", name: "일상", hashTags: ["일상", "가벼운 질문", "아이스브레이킹"]),
    Category(categoryCode: "01", name: "친구", hashTags: ["친구", "우정", "기억"]),
    Category(categoryCode: "02", name: "대학생", hashTags: ["대학생", "학교생활", "시험"]),
    Category(categoryCode: "03", name: "진로", hashTags: ["진로", "미래", "목표"]),
    Category(categoryCode: "04", name: "인생", hashTags: ["인생", "철학", "삶의 의미"]),
    Category(categoryCode: "05", name: "밸런스게임", hashTags: ["꿀잼", "게임", "밸런스"]),
    Category(
        categoryCode: "06",
        name: "꿀잼질문",
        hashTags: ["꿀잼", "남/여사친", "연애", "곤란한질문"]),
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 선택'),
      ),
      body: Padding(
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
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionScreen(
                        categoryCode: categories[index].categoryCode,
                        categoryName: categories[index].name,
                      ),
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
                                        color: Colors.white, fontSize: 12.0),
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
      ),
    );
  }
}
