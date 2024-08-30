import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/game_data.dart';
import '../../data/question_data.dart';
import '../../models/question.dart';
import '../../utils/debounce.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/roulette_widget.dart';
import './ad_banner_widget.dart';

class QuestionScreen extends StatefulWidget {
  final String categoryCode;
  final String categoryName;

  const QuestionScreen({
    super.key,
    required this.categoryCode,
    required this.categoryName,
  });

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Question> questions = [];
  late SharedPreferences prefs;
  Color primaryColor = const Color(0xff303030);

  BannerAd? _bannerAd;
  final bool _isBannerAdReady = false;

  bool isGameSettingOn = true;
  Timer? _viewedTimer;
  int _currentIndex = 0;
  final SwiperController _swiperController = SwiperController();

  final _saveDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  final _loadMoreDebouncer =
      Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    _loadPreferences().then((_) {
      _loadQuestions();
    });
    _setPrimaryColor();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    isGameSettingOn = prefs.getBool('game_setting') ?? true;
  }

  void _setPrimaryColor() {
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
      case "연애":
        primaryColor = const Color(0xffF66F48);
        break;
      default:
        primaryColor = const Color(0xff303030);
        break;
    }
    setState(() {});
  }

  void _insertGameCard(List<Question> questionsList) {
    if (questionsList.length <= 5) {
      return;
    }
    int randomIndex = (questionsList.length * 0.9).toInt();
    String randomGameCard = gameCardData[Random().nextInt(gameCardData.length)];
    questionsList.insert(
        randomIndex, Question(text: randomGameCard, questionNo: -5));
  }

  void _loadQuestions() {
    List<String> viewedQuestions =
        prefs.getStringList(widget.categoryCode) ?? [];

    List<Question> filteredQuestions = questionList
        .where((questionModel) =>
            questionModel.categoryCode == widget.categoryCode)
        .expand((questionModel) => questionModel.questions)
        .where((question) => !viewedQuestions
            .contains("${widget.categoryCode}:${question.questionNo}"))
        .toList()
      ..shuffle();

    if (filteredQuestions.isEmpty) {
      setState(() {
        questions = [
          Question(text: "모든 질문을 확인하셨습니다.\n다시 리셋하시겠습니까?", questionNo: -4)
        ];
      });
      return;
    }

    filteredQuestions.insert(
        0, Question(text: "아래에서 위로 스와이프를 해서 질문을 확인하세요!", questionNo: -1));

    List<Question> initialQuestions = filteredQuestions.take(11).toList();

    if (filteredQuestions.length > 11) {
      initialQuestions.add(Question(text: "질문 더 불러오기", questionNo: -2));
    } else if (filteredQuestions.length > 1 && filteredQuestions.length <= 11) {
      initialQuestions.add(Question(text: "질문 더 불러오기", questionNo: -2));
    }

    if (isGameSettingOn) {
      _insertGameCard(initialQuestions);
    }

    setState(() {
      questions = initialQuestions;
    });
  }

  void _startViewedTimer() {
    _viewedTimer?.cancel();
    _viewedTimer = Timer(const Duration(seconds: 1), () {
      _markAsViewed(questions[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _viewedTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _markAsViewed(Question question) {
    List<String> viewedQuestions =
        prefs.getStringList(widget.categoryCode) ?? [];
    viewedQuestions.add("${widget.categoryCode}:${question.questionNo}");
    prefs.setStringList(widget.categoryCode, viewedQuestions);
  }

  void _resetViewedQuestions() {
    prefs.remove(widget.categoryCode);
    _loadQuestions();
  }

  Future<void> _loadMoreQuestions() async {
    _loadMoreDebouncer.run(() {
      List<String> viewedQuestions =
          prefs.getStringList(widget.categoryCode) ?? [];

      List<Question> moreQuestions = questionList
          .where((questionModel) =>
              questionModel.categoryCode == widget.categoryCode)
          .expand((questionModel) => questionModel.questions)
          .where((question) => !viewedQuestions
              .contains("${widget.categoryCode}:${question.questionNo}"))
          .skip(questions.length)
          .take(11)
          .toList();

      int remainingQuestionsCount = questionList
          .where((questionModel) =>
              questionModel.categoryCode == widget.categoryCode)
          .expand((questionModel) => questionModel.questions)
          .where((question) => !viewedQuestions
              .contains("${widget.categoryCode}:${question.questionNo}"))
          .skip(questions.length)
          .length;

      questions.removeWhere((question) => question.questionNo == -2);

      if (isGameSettingOn && moreQuestions.length > 5) {
        _insertGameCard(moreQuestions);
      }

      setState(() {
        questions.addAll(moreQuestions);
        if (remainingQuestionsCount > 0 && remainingQuestionsCount > 11) {
          questions.add(Question(text: "질문 더보기", questionNo: -2));
        }
        if (remainingQuestionsCount <= 11) {
          questions.add(Question(text: "질문을 모두 보셨습니다.", questionNo: -3));
        }
      });
    });
  }

  void _savedQuestion(Question question) async {
    _saveDebouncer.run(() async {
      String? savedQuestionsJson = prefs.getString('saved_questions');
      Map<String, dynamic> savedQuestionsMap = {};

      try {
        if (savedQuestionsJson != null && savedQuestionsJson.isNotEmpty) {
          savedQuestionsMap = json.decode(savedQuestionsJson);
        }

        if (savedQuestionsMap.containsKey(widget.categoryCode)) {
          List<Map<String, dynamic>> categoryQuestions =
              List<Map<String, dynamic>>.from(
                  savedQuestionsMap[widget.categoryCode]);
          if (categoryQuestions
              .any((q) => q['questionNo'] == question.questionNo)) {
            showCustomSnackBar(context, "이미 저장된 질문입니다.", isSuccess: false);
            return;
          }
        } else {
          savedQuestionsMap[widget.categoryCode] = [];
        }

        List<dynamic> categoryQuestions =
            savedQuestionsMap[widget.categoryCode];
        categoryQuestions.add({
          'questionNo': question.questionNo,
          'text': question.text,
        });

        String updatedSavedQuestionsJson = json.encode(savedQuestionsMap);
        await prefs.setString('saved_questions', updatedSavedQuestionsJson);
        showCustomSnackBar(context, "저장 성공!", isSuccess: true);
      } catch (e) {
        showCustomSnackBar(context, "저장 실패.", isSuccess: false);
      }
    });
  }

  void _showRouletteModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            width: 250,
            height: 300,
            child: RouletteWidget(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: questions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Swiper(
                    controller: _swiperController,
                    loop: false,
                    onIndexChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      _startViewedTimer();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (questions[index].questionNo == -1) {
                        return Card(
                          color: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swipe_up_outlined,
                                size: 60,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                questions[index].text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xff2f2f2f),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (questions[index].questionNo == -2) {
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
                                        Colors.blueGrey),
                                  ),
                                  onPressed: _loadMoreQuestions,
                                  child: Text(
                                    questions[index].text,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'HamChorong',
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (questions[index].questionNo == -3) {
                        return Card(
                          color: Colors.grey,
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
                                  fontFamily: 'HamChorong',
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (questions[index].questionNo == -4) {
                        return Card(
                          color: Colors.grey,
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
                                      fontFamily: 'HamChorong',
                                    ),
                                  ),
                                  const SizedBox(height: 40),
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
                                        fontFamily: 'HamChorong',
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else if (questions[index].questionNo == -5) {
                        return Card(
                          color: Colors.yellow.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Stack(
                            children: [
                              const Positioned(
                                top: 8.0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20.0),
                                    child: Text(
                                      "GAME CARD",
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontFamily: 'HamChorong',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.red, width: 2.0),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      questions[index].text,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'HamChorong',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: Text(
                                    widget.categoryName,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'HamChorong',
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
                                      fontFamily: 'HamChorong',
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
          ),
          Positioned(
            top: screenHeight * 0.05,
            right: 0.0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          if (questions.isNotEmpty && questions[_currentIndex].questionNo > 0)
            Positioned(
              top: screenHeight * 0.05,
              left: 0.0,
              child: IconButton(
                icon: const Icon(
                  Icons.bookmark_add,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  _savedQuestion(questions[_currentIndex]);
                },
              ),
            ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth / 2 - 32,
            child: IconButton(
              icon: const Icon(
                Icons.explore,
                size: 32,
                color: Colors.white,
              ),
              onPressed: _showRouletteModal,
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AdBannerWidget(),
          ),
        ],
      ),
    );
  }
}
