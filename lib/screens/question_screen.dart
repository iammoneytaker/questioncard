import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/question_data.dart';
import '../models/question.dart';

class QuestionScreen extends StatefulWidget {
  final String categoryCode;
  final String categoryName;

  const QuestionScreen(
      {super.key, required this.categoryCode, required this.categoryName});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Question> questions = [];
  late SharedPreferences prefs;
  Color primaryColor = const Color(0xff303030);

  // 카드들에 대한 상태값
  Timer? _viewedTimer; // Timer 객체
  int _currentIndex = 0; // 현재 보이는 카드의 인덱스
  final SwiperController _swiperController =
      SwiperController(); // Swiper 컨트롤러 추가
  // 카드들에 대한 상태값

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPreferences().then((_) {
      _loadQuestions();
    });
    _setPrimaryColor();
  }

  _setPrimaryColor() {
    // 카테고리에 따라 다른 색상의 주요 색상.
    switch (widget.categoryName) {
      case "일상":
        primaryColor = const Color(0xffCD2E6C);
        break;
      case "친구":
        primaryColor = const Color(0xff4FBEE5);
        break;
      case "대학생":
        primaryColor = const Color(0xffA799F8);
        break;
      case "진로":
        primaryColor = const Color(0xff303030);
        break;
      case "인생":
        primaryColor = const Color(0xff18413E);
        break;
      case "밸런스게임":
        primaryColor = const Color(0xff7EA090);
        break;
      case "꿀잼질문":
        primaryColor = const Color(0xffF66F48);
        break;
      default:
        primaryColor = const Color(0xff303030);
        break;
    }
    setState(() {});
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  _loadQuestions() {
    List<String> viewedQuestions =
        prefs.getStringList(widget.categoryCode) ?? [];

    // 해당 카테고리의 질문 중 사용자가 보지 않은 질문만 필터링
    List<Question> filteredQuestions = questionList
        .where((questionModel) =>
            questionModel.categoryCode == widget.categoryCode)
        .expand((questionModel) => questionModel.questions)
        .where((question) => !viewedQuestions
            .contains("${widget.categoryCode}:${question.questionNo}"))
        .toList();

    // 모든 질문을 확인한 경우
    if (filteredQuestions.isEmpty) {
      setState(() {
        questions = [
          Question(text: "모든 질문을 확인하셨습니다.\n다시 리셋하시겠습니까?", questionNo: -4)
        ];
      });
      return;
    }

    // 맨 앞에 특별한 카드 추가
    filteredQuestions.insert(
        0, Question(text: "아래에서 위로 스와이프를 해서 질문을 확인하세요!", questionNo: -1));

    // 처음 11개의 질문만 로드
    List<Question> initialQuestions = filteredQuestions.take(11).toList();

    // "광고 보고 질문 더보기" 카드 추가
    if (filteredQuestions.length > 11) {
      initialQuestions.add(Question(text: "광고 보고 질문 더보기", questionNo: -2));
    } else if (filteredQuestions.length > 1 && filteredQuestions.length <= 11) {
      initialQuestions.add(Question(text: "광고 보고 질문 더보기", questionNo: -2));
    }

    setState(() {
      questions = initialQuestions;
    });
  }

  // 봤을때 3초 뒤에 본 것으로 체크해서 다음부터 안나오게 처리.
  _startViewedTimer() {
    _viewedTimer?.cancel(); // 이전 타이머가 있으면 취소
    _viewedTimer = Timer(const Duration(seconds: 3), () {
      _markAsViewed(questions[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _viewedTimer?.cancel(); // 화면이 종료될 때 타이머를 취소
    super.dispose();
  }

  _markAsViewed(Question question) {
    List<String> viewedQuestions =
        prefs.getStringList(widget.categoryCode) ?? [];
    viewedQuestions.add("${widget.categoryCode}:${question.questionNo}");
    prefs.setStringList(widget.categoryCode, viewedQuestions);
  }

  _resetViewedQuestions() {
    prefs.remove(widget.categoryCode);
    _loadQuestions();
  }

  void _loadMoreQuestionsDebounced() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadMoreQuestions();
    });
  }

  // 현재 로드된 질문 이후의 질문을 가져옵니다.
  void _loadMoreQuestions() {
    List<String> viewedQuestions =
        prefs.getStringList(widget.categoryCode) ?? [];

    // 현재 로드된 질문 이후의 질문을 가져옵니다.
    List<Question> moreQuestions = questionList
        .where((questionModel) =>
            questionModel.categoryCode == widget.categoryCode)
        .expand((questionModel) => questionModel.questions)
        .where((question) => !viewedQuestions
            .contains("${widget.categoryCode}:${question.questionNo}"))
        .skip(questions.length) // 이미 로드된 질문은 건너뜁니다.
        .take(11) // 11개의 질문만 가져옵니다.
        .toList();

    int remainingQuestionsCount = questionList
        .where((questionModel) =>
            questionModel.categoryCode == widget.categoryCode)
        .expand((questionModel) => questionModel.questions)
        .where((question) => !viewedQuestions
            .contains("${widget.categoryCode}:${question.questionNo}"))
        .skip(questions.length) // 이미 로드된 질문은 건너뜁니다.
        .length;

    // "광고 보고 질문 더보기" 카드 제거
    questions.removeWhere((question) => question.questionNo == -2);

    setState(() {
      questions.addAll(moreQuestions);
      // 남아 있는 질문이 있으면 "광고 보고 질문 더보기" 카드 추가
      if (remainingQuestionsCount > 0 && remainingQuestionsCount > 11) {
        questions.add(Question(text: "광고 보고 질문 더보기", questionNo: -2));
      }
      if (remainingQuestionsCount <= 11) {
        questions.add(Question(text: "질문을 모두 보셨습니다.", questionNo: -3));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Stack(
          children: [
            questions.isEmpty
                ? const Center(
                    child: CircularProgressIndicator()) // 로딩 인디케이터 추가
                : Swiper(
                    controller: _swiperController, // Swiper에 컨트롤러 연결
                    loop: false,
                    onIndexChanged: (index) {
                      _currentIndex = index;
                      _startViewedTimer(); // 카드가 바뀔 때마다 타이머 시작
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (questions[index].questionNo == -1) {
                        // 특별한 카드 렌더링
                        return Card(
                          color: Colors.grey.shade300, // 또는 원하는 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                questions[index].text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (questions[index].questionNo == -2) {
                        // 광고 카드
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.blueGrey,
                                    ),
                                  ),
                                  onPressed: _loadMoreQuestionsDebounced,
                                  child: Text(
                                    questions[index].text,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (questions[index].questionNo == -3) {
                        // 질문 끝!
                        return Card(
                          color: Colors.grey, // 또는 원하는 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                questions[index].text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (questions[index].questionNo == -4) {
                        // 모든 질문 다 확인했을 경우
                        return Card(
                          color: Colors.grey, // 또는 원하는 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    questions[index].text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      height: 2,
                                      fontSize: 16.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.deepPurple,
                                      ),
                                    ),
                                    onPressed: _resetViewedQuestions,
                                    child: const Text(
                                      'RESET',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        // 일반 카드 렌더링
                        // 일반 카드 렌더링
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Stack(
                            children: [
                              // 카테고리 이름을 카드의 맨 위 중앙에 위치시킵니다.
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0), // 상단 패딩으로 조정
                                  child: Text(
                                    widget.categoryName, // 카테고리 이름
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    questions[index].text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemCount: questions.length,
                    viewportFraction: 0.7,
                    scale: 0.2,
                    scrollDirection: Axis.vertical,
                  ),
            Positioned(
              top: 40.0,
              right: 20.0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  // Handle the close action
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
