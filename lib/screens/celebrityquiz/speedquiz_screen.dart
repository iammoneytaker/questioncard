import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/ad_data.dart';
import '../../data/celebrityquiz_data.dart';

class SpeedQuizScreen extends StatefulWidget {
  final String category;
  const SpeedQuizScreen({Key? key, required this.category}) : super(key: key);

  @override
  _SpeedQuizScreenState createState() => _SpeedQuizScreenState();
}

const Color primaryColor = Color(0xffF5988D);

class _SpeedQuizScreenState extends State<SpeedQuizScreen> {
  Timer? _timer;
  Timer? _imageTimer;
  int _currentIndex = 0;
  bool _isStarted = false;
  bool _isCountdownVisible = false;
  int _timeLeft = 3;
  int _imageTimeLeft = 1;
  List<Map<String, String>> _filteredCelebrityList = []; // 필터링된 연예인 리스트
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = true;

  bool _showImage = true; // 이미지를 보여줄지 여부
  bool _showAnswerCheck = false; // '정답 확인하기' 버튼을 보여줄지 여부
  bool _showNextQuestion = false; // '다음 문제' 버튼을 보여줄지 여부
  bool _bShowAnswer = false;
  bool _noMoreImages = false;

  final Color backgroundColor = const Color(0xfffffff0);
  bool _showCardWidget = false; // Add this new state variable

  @override
  void initState() {
    super.initState();
    _loadFilteredCelebrityList();
  }

  Future<void> _loadFilteredCelebrityList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? celebrityDataJson = prefs.getString('celebrityData');
    final Map<String, dynamic> celebrityData = celebrityDataJson != null
        ? json.decode(celebrityDataJson) as Map<String, dynamic>
        : {};

    List<String> viewedCelebrities =
        List<String>.from(celebrityData[widget.category] ?? []);

    // 필터링된 리스트를 가져온 후에 리스트를 섞습니다.
    final List<Map<String, String>> filteredList =
        celebrityquizData[widget.category]!.where((celebrity) {
      final celebrityName = celebrity.keys.first;
      return !viewedCelebrities.contains(celebrityName);
    }).toList()
          ..shuffle(); // 이 부분에서 리스트를 섞습니다.

    // Set the shuffled and filtered list to state
    setState(() {
      _filteredCelebrityList = filteredList;
      isLoading = false;
    });
  }

  // 본 연예인들의 이름을 저장하는 메서드
  Future<void> _saveViewedCelebrity(
      String category, String celebrityName) async {
    final SharedPreferences prefs = await _prefs;
    // JSON 문자열을 Map 객체로 변환
    final String? celebrityDataJson = prefs.getString('celebrityData');
    Map<String, dynamic> celebrityData = celebrityDataJson != null
        ? json.decode(celebrityDataJson) as Map<String, dynamic>
        : {};

    // 카테고리에 해당하는 리스트를 업데이트
    List<String> viewedCelebrities =
        List<String>.from(celebrityData[category] ?? []);
    viewedCelebrities.add(celebrityName);
    celebrityData[category] = viewedCelebrities;

    // JSON 문자열로 변환하여 저장
    prefs.setString('celebrityData', json.encode(celebrityData));
  }

  void _startQuiz() {
    setState(() {
      _isStarted = true;
      _isCountdownVisible = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 3;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        setState(() {
          _isCountdownVisible = false;
        });
        _showCard();
      }
    });
  }

  void _showCard() async {
    setState(() {
      _showCardWidget = true; // 카드 위젯 보여줌
      _showImage = true; // 이미지 보여줌
      _imageTimeLeft = 1; // 이미지 타이머 시간 설정
    });
    await _saveViewedCelebrity(
        widget.category, _filteredCelebrityList.first.keys.first);

    // 이미지 타이머 시작
    _imageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_imageTimeLeft > 0) {
        setState(() => _imageTimeLeft--);
      } else {
        // 이미지 타이머 종료 후, 정답 확인 및 다음 문제 버튼 보여줌
        _imageTimer?.cancel();
        setState(() {
          _showImage = false; // 이미지 숨김
          _showAnswerCheck = true; // '정답 확인하기' 버튼 보여줌
          _showNextQuestion = true; // '다음 문제' 버튼 보여줌
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    _imageTimer?.cancel(); // 이미지 타이머 취소
    super.dispose();
  }

// 이 메서드는 광고가 성공적으로 보여졌을 때 호출됩니다.
  void showRewardFullBanner(BuildContext context, Function callback) async {
    bool isCallbackCalled = false;

    void safeCallback() {
      if (!isCallbackCalled) {
        isCallbackCalled = true;
        callback();
      }
    }

    await RewardedInterstitialAd.load(
      adUnitId: REWARD_INTERSTRITIAL_ADID,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback:
          RewardedInterstitialAdLoadCallback(onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
            print('Ad dismissed.');
            ad.dispose();
            safeCallback();
          },
          onAdFailedToShowFullScreenContent:
              (RewardedInterstitialAd ad, AdError error) {
            print('Ad failed to show.');
            ad.dispose();
            safeCallback();
          },
        );

        ad.show(onUserEarnedReward: (ad, reward) {
          print('Reward earned.');
          _initializeQuiz(); // 광고 보상 후 퀴즈 초기화
          safeCallback();
        });
      }, onAdFailedToLoad: (error) {
        print('Ad failed to load: $error');
        safeCallback();
      }),
    );
  }

// 이 메서드는 모든 이미지를 본 후에 호출되며, 퀴즈 상태를 초기화합니다.
  void _initializeQuiz() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('celebrityData', json.encode({widget.category: []}));
    setState(() {
      _isStarted = false;
      _isCountdownVisible = false;
      _showCardWidget = false;
      _showImage = true;
      _showAnswerCheck = false;
      _showNextQuestion = false;
      _bShowAnswer = false;
      _noMoreImages = false;
      _currentIndex = 0;
      isLoading = false;
    });
    await _loadFilteredCelebrityList(); // 새 데이터 로드
  }

// 이 메서드는 리셋 버튼을 클릭했을 때 호출됩니다.
  Future<void> _resetViewedCelebrities() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "광고 로드 중입니다..\n잠시만 기다려주세요..",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );

    // 광고를 보여주고, 사용자가 광고를 보면 퀴즈를 초기화합니다.
    showRewardFullBanner(context, () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      _initializeQuiz(); // 퀴즈 상태 초기화
    });
  }

  // '정답 확인하기' 버튼 로직
  void _showAnswer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "광고 로드 중입니다..\n잠시만 기다려주세요..",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
    void showRewardFullBanner2(BuildContext context, Function callback) async {
      bool isCallbackCalled = false; // 콜백 호출 여부를 추적하는 플래그

      void safeCallback() {
        if (!isCallbackCalled) {
          isCallbackCalled = true;
          callback();
        }
      }

      await RewardedInterstitialAd.load(
        adUnitId: REWARD_INTERSTRITIAL_ADID,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
              print('Ad dismissed.');
              ad.dispose();
              safeCallback();
            },
            onAdFailedToShowFullScreenContent:
                (RewardedInterstitialAd ad, AdError error) {
              print('Ad failed to show.');
              ad.dispose();
              safeCallback(); // 추가적인 콜백 로직이 있다면 여기서 호출합니다.
            },
          );

          ad.show(onUserEarnedReward: (ad, reward) {
            print('Reward earned.');
            safeCallback(); // 광고 시청 보상 후 초기화 콜백 호출
          });
        }, onAdFailedToLoad: (error) {
          print('Ad failed to load: $error');
          safeCallback(); // 광고 로드 실패 시 초기화 콜백 호출
        }),
      );
    }

    // 광고를 보여주고, 사용자가 광고를 보면 퀴즈를 초기화합니다.
    showRewardFullBanner2(context, () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      setState(() {
        _showImage = true; // 이미지를 다시 보여줌
        _showAnswerCheck = false; // '정답 확인하기' 버튼 숨김
        _bShowAnswer = true;
      });
    });
  }

  void _handleCompleteCycle() {
    setState(() {
      _noMoreImages = true;
      _showCardWidget = true;
      _showImage = false;
      _showAnswerCheck = false;
      _showNextQuestion = false;
      _bShowAnswer = false;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _filteredCelebrityList.length - 1) {
      setState(() {
        _currentIndex++;
        _showImage = false;
        _showAnswerCheck = false;
        _showNextQuestion = false;
        _bShowAnswer = false;
        _startQuiz();
      });
    } else {
      _handleCompleteCycle();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSize = screenWidth * 0.9;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Speed Quiz'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.center,
              children: [
                if (_noMoreImages)
                  Center(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: cardSize,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '모든 이미지를 보셨습니다.',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HamChorong',
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            ElevatedButton(
                              onPressed: _resetViewedCelebrities,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                              ),
                              child: const Text(
                                '리셋하기',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!_isStarted && _filteredCelebrityList.isNotEmpty)
                  Center(
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                      ),
                      child: const Text('Start!'),
                    ),
                  ),
                if (_isCountdownVisible)
                  CountdownAnimation(
                    key: UniqueKey(),
                    countdownStart: _timeLeft,
                  ),
                // New card widget that will be displayed after countdown
                if (_showCardWidget &&
                    _filteredCelebrityList.isNotEmpty &&
                    _showImage)
                  Center(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: cardSize,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/persongame/${widget.category}/${_filteredCelebrityList[_currentIndex].values.first}.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _bShowAnswer
                                ? Column(
                                    children: [
                                      Text(
                                        _filteredCelebrityList[_currentIndex]
                                            .keys
                                            .first,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _nextQuestion,
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  primaryColor),
                                        ),
                                        child: const Text('다음 문제'),
                                      ),
                                    ],
                                  )
                                : Text(
                                    '$_imageTimeLeft초 남았습니다.',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // The rest of your PageView.builder and other widgets...
                // Add your buttons for 'Check Answer' and 'Next' here
                if (_filteredCelebrityList.isEmpty)
                  Center(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: cardSize,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '모든 이미지를 보셨습니다.',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HamChorong',
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            ElevatedButton(
                              onPressed: _resetViewedCelebrities,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                              ),
                              child: const Text(
                                '리셋하기',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_showAnswerCheck && _showNextQuestion)
                  Center(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: cardSize,
                        height: cardSize,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _showAnswer,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                              ),
                              child: const Text('정답 확인하기'),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                              ),
                              child: const Text('다음 문제'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class CountdownAnimation extends StatefulWidget {
  final int countdownStart;

  const CountdownAnimation({
    Key? key,
    required this.countdownStart,
  }) : super(key: key);

  @override
  State<CountdownAnimation> createState() => _CountdownAnimationState();
}

class _CountdownAnimationState extends State<CountdownAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _countdownTime;

  @override
  void initState() {
    super.initState();
    _countdownTime = widget.countdownStart;
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_countdownTime > 1) {
            setState(() {
              _countdownTime--;
            });
            _controller.reset(); // Instead of reverse, reset the controller
          } else {
            // Do not dispose the controller here
          }
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Ensure the controller is disposed here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_countdownTime',
                style: TextStyle(
                  fontSize: 150 * _animation.value,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
