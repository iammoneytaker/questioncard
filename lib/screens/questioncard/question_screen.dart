import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/ad_data.dart';
import '../../data/game_data.dart';
import '../../data/question_data.dart';
import '../../models/question.dart';
import '../../utils/debounce.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/roulette_widget.dart';

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

  // AD STATE
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  // AD STATE

  bool isGameSettingOn = true; // 게임 설정 기본값
  // 카드들에 대한 상태값
  Timer? _viewedTimer; // Timer 객체
  int _currentIndex = 0; // 현재 보이는 카드의 인덱스
  final SwiperController _swiperController =
      SwiperController(); // Swiper 컨트롤러 추가
  // 카드들에 대한 상태값

  // 함수 Debouncer
  final _saveDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  final _loadMoreDebouncer =
      Debouncer(delay: const Duration(milliseconds: 300));
  // 함수 Debouncer

  @override
  void initState() {
    super.initState();
    _loadPreferences().then((_) {
      _loadQuestions();
    });
    _setPrimaryColor();
    _loadBannerAd();
  }

  _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: BANNER_ADID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded.');
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$ad failed to load: $error');
          ad.dispose();
          setState(() {
            _isBannerAdReady = false;
          });
        },
      ),
    );
    _bannerAd!.load();
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
      case "연애":
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
    isGameSettingOn = prefs.getBool('game_setting') ?? true; // 게임 설정값 불러오기
  }

  _insertGameCard(List<Question> questionsList) {
    if (questionsList.length <= 5) {
      return; // 질문 카드가 5개 이하면 함수를 종료하고 게임 카드를 추가하지 않습니다.
    }
    int randomIndex = (questionsList.length * 0.9).toInt();
    String randomGameCard = gameCardData[Random().nextInt(gameCardData.length)];
    questionsList.insert(
        randomIndex,
        Question(
            text: randomGameCard,
            questionNo: -5)); // -5는 게임 카드를 나타내는 임의의 번호입니다.
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
        .toList()
      ..shuffle();

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
      initialQuestions.add(Question(text: "질문 더 불러오기", questionNo: -2));
    } else if (filteredQuestions.length > 1 && filteredQuestions.length <= 11) {
      initialQuestions.add(Question(text: "질문 더 불러오기", questionNo: -2));
    }

    // 게임 설정이 ON인 경우 10개의 질문 카드 중 1개의 게임 카드를 랜덤하게 추가
    if (isGameSettingOn) {
      _insertGameCard(initialQuestions); // 여기를 수정했습니다.
    }

    setState(() {
      questions = initialQuestions;
    });
  }

  // 봤을때 3초 뒤에 본 것으로 체크해서 다음부터 안나오게 처리.
  _startViewedTimer() {
    _viewedTimer?.cancel(); // 이전 타이머가 있으면 취소
    _viewedTimer = Timer(const Duration(seconds: 1), () {
      _markAsViewed(questions[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _viewedTimer?.cancel(); // 화면이 종료될 때 타이머를 취소
    _bannerAd?.dispose();
    super.dispose();
  }

  // 본 질문 리스트들에 대한 데이터 정보 저장
  _markAsViewed(Question question) {
    List<String> viewedQuestions =
        prefs.getStringList(widget.categoryCode) ?? [];
    viewedQuestions.add("${widget.categoryCode}:${question.questionNo}");
    prefs.setStringList(widget.categoryCode, viewedQuestions);
  }

  // 질문들 다 봤을 때 리셋시키는 함수.
  _resetViewedQuestions() {
    prefs.remove(widget.categoryCode);
    _loadQuestions();
  }

  // 현재 로드된 질문 이후의 질문을 가져옵니다.
  void _loadMoreQuestions() {
    _loadMoreDebouncer.run(() {
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

      // "질문 더 불러오기 질문 더보기" 카드 제거
      questions.removeWhere((question) => question.questionNo == -2);

      // 게임 설정이 ON인 경우 10개의 질문 카드 중 1개의 게임 카드를 랜덤하게 추가
      if (isGameSettingOn && moreQuestions.length > 5) {
        // 5개 이상일 때만 게임 카드 추가
        _insertGameCard(moreQuestions);
      }
      _bannerAd?.dispose();
      _loadBannerAd();

      setState(() {
        questions.addAll(moreQuestions);
        // 남아 있는 질문이 있으면 "질문 더 불러오기 질문 더보기" 카드 추가
        if (remainingQuestionsCount > 0 && remainingQuestionsCount > 11) {
          questions.add(Question(text: "질문 더보기", questionNo: -2));
        }
        if (remainingQuestionsCount <= 11) {
          questions.add(Question(text: "질문을 모두 보셨습니다.", questionNo: -3));
        }
      });
    });
  }

  // 정보 저장 ( 질문 저장 )
  _savedQuestion(Question question) async {
    _saveDebouncer.run(() async {
      // 1. SharedPreferences에서 현재 저장된 북마크 데이터를 가져옵니다.
      String? savedQuestionsJson = prefs.getString('saved_questions');
      Map<String, dynamic> savedQuestionsMap = {};

      try {
        // 2. 가져온 데이터를 Dart의 Map 형식으로 변환합니다.
        if (savedQuestionsJson != null && savedQuestionsJson.isNotEmpty) {
          savedQuestionsMap = json.decode(savedQuestionsJson);
        }

        // 3. 해당 카테고리에 질문을 추가하거나 업데이트합니다.
        // 3. 해당 카테고리에 질문이 이미 저장되어 있는지 확인합니다.
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

        // 4. Map을 다시 JSON 문자열로 변환하여 SharedPreferences에 저장합니다.
        String updatedSavedQuestionsJson = json.encode(savedQuestionsMap);
        await prefs.setString('saved_questions', updatedSavedQuestionsJson);
        // 저장 로직
        showCustomSnackBar(context, "저장 성공!", isSuccess: true);
      } catch (e) {
        showCustomSnackBar(context, "저장 실패.", isSuccess: false);
      }
    });
  }

// 룰렛 아이콘 버튼 클릭 시 호출되는 함수
  void _showRouletteModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            width: 250,
            height: 300, // 높이를 조금 더 늘려서 버튼들이 잘 보이게 합니다.
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
                      setState(() {
                        _currentIndex = index;
                      });
                      _bannerAd?.dispose();
                      _loadBannerAd();
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
                                  fontFamily: 'HamChorong',
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
                                      fontFamily: 'HamChorong',
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
                        // 게임 카드 렌더링
                        return Card(
                          color: Colors.yellow.shade200, // 게임 카드의 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Stack(
                            children: [
                              // "GAME" 텍스트 추가
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
                              // 빨간색 테두리와 텍스트 추가
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
            Positioned(
              top: screenHeight * 0.05, // 예: 화면 높이의 10% 위치
              right: 0.0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () {
                  // Handle the close action
                  Navigator.pop(context);
                },
              ),
            ),
            if (questions.isNotEmpty && questions[_currentIndex].questionNo > 0)
              Positioned(
                top: screenHeight * 0.05, // 예: 화면 높이의 10% 위치
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
              top: screenHeight * 0.05, // 예: 화면 높이의 10% 위치
              left: screenWidth / 2 - 32,
              child: IconButton(
                icon: const Icon(
                  Icons.explore,
                  size: 32,
                  color: Colors.white,
                ), // 룰렛 아이콘
                onPressed: _showRouletteModal,
              ),
            ),
            Positioned(
              bottom: 0.0,
              child: _isBannerAdReady
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50, // 배너 광고의 높이
                      child: AdWidget(ad: _bannerAd!),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
