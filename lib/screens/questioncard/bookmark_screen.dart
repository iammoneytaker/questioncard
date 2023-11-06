import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/category_data.dart';
import '../../models/question.dart';

class BookMarkScreen extends StatefulWidget {
  const BookMarkScreen({super.key});

  @override
  _BookMarkScreenState createState() => _BookMarkScreenState();
}

class _BookMarkScreenState extends State<BookMarkScreen> {
  String selectedCategory = "전체"; // 기본으로 전체 카테고리 선택
  late SharedPreferences prefs;
  Map<String, List<Question>> savedQuestions = {};

  @override
  void initState() {
    super.initState();
    _loadSavedQuestions();
  }

  Future<void> _loadSavedQuestions() async {
    prefs = await SharedPreferences.getInstance();
    String? savedQuestionsJson = prefs.getString('saved_questions');
    if (savedQuestionsJson != null && savedQuestionsJson.isNotEmpty) {
      Map<String, dynamic> savedQuestionsMap = json.decode(savedQuestionsJson);
      savedQuestionsMap.forEach((categoryCode, questions) {
        savedQuestions[categoryCode] = (questions as List)
            .map((question) => Question(
                  text: question['text'],
                  questionNo: question['questionNo'],
                ))
            .toList();
      });
      print(savedQuestions);
      setState(() {});
    }
  }

  String getCategoryNameByCode(String categoryCode) {
    return categories
        .firstWhere((category) => category.categoryCode == categoryCode)
        .name;
  }

  Future<void> _deleteQuestion(String categoryCode, Question question) async {
    if (savedQuestions.containsKey(categoryCode)) {
      savedQuestions[categoryCode]!.remove(question);
      if (savedQuestions[categoryCode]!.isEmpty) {
        savedQuestions.remove(categoryCode);
      }
      await _saveQuestionsToPrefs();
      setState(() {});
    }
  }

  Future<void> _saveQuestionsToPrefs() async {
    Map<String, dynamic> savedQuestionsMap = {};
    savedQuestions.forEach((key, value) {
      savedQuestionsMap[key] = value
          .map((q) => {
                'text': q.text,
                'questionNo': q.questionNo,
              })
          .toList();
    });
    await prefs.setString('saved_questions', json.encode(savedQuestionsMap));
  }

  Widget _buildCategoryButton(String categoryName) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = categoryName;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == categoryName
            ? const Color(0xffF66F48) // 선택된 버튼의 색상
            : Colors.grey[300], // 선택되지 않은 버튼의 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 버튼을 동그랗게 만듦
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 크기 조절
      ),
      child: Text(categoryName,
          style: TextStyle(
              fontWeight: selectedCategory == categoryName
                  ? FontWeight.bold // 선택된 버튼의 색상
                  : FontWeight.w300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? selectedCategoryCode;
    if (selectedCategory != "전체") {
      selectedCategoryCode = categories
          .firstWhere((category) => category.name == selectedCategory)
          .categoryCode;
    }

    List<Question> displayedQuestions = [];
    if (selectedCategory == "전체") {
      for (var list in savedQuestions.values) {
        displayedQuestions.addAll(list);
      }
    } else if (selectedCategoryCode != null) {
      displayedQuestions = savedQuestions[selectedCategoryCode] ?? [];
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildCategoryButton("전체"),
                ...categories
                    .map((category) => _buildCategoryButton(category.name)),
              ],
            ),
            Expanded(
              child: displayedQuestions.isNotEmpty
                  ? ListView.builder(
                      itemCount: displayedQuestions.length,
                      itemBuilder: (context, index) {
                        Question question = displayedQuestions[index];
                        return Card(
                          margin: const EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            title: Text(question.text),
                            trailing: GestureDetector(
                              onTap: () async {
                                String categoryCodeForQuestion = savedQuestions
                                    .entries
                                    .firstWhere((entry) =>
                                        entry.value.contains(question))
                                    .key;
                                await _deleteQuestion(
                                    categoryCodeForQuestion, question);
                              },
                              child: const Icon(
                                Icons.delete,
                                size: 24.0,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              // 카드를 탭했을 때의 동작을 여기에 작성하세요.
                            },
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "데이터가 존재하지 않습니다",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
