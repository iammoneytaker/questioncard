import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../data/ad_data.dart';
import '../../data/celebrityquiz_data.dart';
import '../../widgets/custom_snackbar.dart';

class ZoomInScreen extends StatefulWidget {
  final String category; // actor | idol | comedian
  const ZoomInScreen({super.key, required this.category});

  @override
  _ZoomInScreenState createState() => _ZoomInScreenState();
}

class _ZoomInScreenState extends State<ZoomInScreen> {
  final double _initialScale = 10.0; // 초기 확대 비율을 나타내는 상수
  late double _scale; // 현재 확대 비율
  final List<double> _scaleHistory = []; // 줌 레벨의 이력을 저장하는 스택
  int _currentStep = 1; // 현재 단계
  final int _maxStep = 10; // 최대 단계
  int _currentIndex = 0; // 현재 보이는 이미지의 인덱스
  final SwiperController _swiperController =
      SwiperController(); // Swiper 컨트롤러 추가

  final Color primaryColor = const Color(0xffF5988D);
  final Color backgroundColor = const Color(0xfffffff0);
  String? _answer; // 정답을 저장할 변수

  void _showAnswer() {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 다이얼로그 외부를 터치하여 닫을 수 없게 함
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                // Expanded 위젯 사용
                child: Text(
                  "광고 로드 중 입니다..\n잠시만 기다려주세요..(🥹)",
                  textAlign: TextAlign.center, // 텍스트 정렬
                ),
              ),
            ],
          ),
        );
      },
    );

    showRewardFullBanner(context, () async {
      print('!?');
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      try {
        setState(() {
          _answer =
              celebrityquizData[widget.category]![_currentIndex].keys.first;
        });
      } catch (e) {
        showCustomSnackBar(
          context,
          "정답을 불러오는데에 실패했습니다..",
          isSuccess: false,
        );
      }
    });
    // 현재 인덱스의 정답을 _answer에 저장하고 UI를 업데이트합니다.
  }

  void _zoomOut() {
    if (_currentStep < _maxStep) {
      _scaleHistory.add(_scale); // 현재 줌 레벨을 이력에 추가
      setState(() {
        _scale = (_scale > 1) ? _scale - 1 : 1; // 확대 비율을 줄임
        _currentStep++; // 다음 단계로 이동
      });
    }
  }

  void _zoomIn() {
    if (_scaleHistory.isNotEmpty) {
      setState(() {
        _scale = _scaleHistory.removeLast(); // 마지막 줌 레벨로 되돌림
        _currentStep = (_currentStep > 1) ? _currentStep - 1 : 1; // 이전 단계로 이동
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scale = _initialScale;
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index; // 새로운 인덱스로 업데이트
      _scale = _initialScale; // 스케일을 초기 값으로 재설정
      _scaleHistory.clear(); // 줌 이력을 클리어
      _currentStep = 1; // 현재 단계를 초기화
      _answer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerSize = screenWidth * 0.9; // 화면 너비의 90% 크기

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Swiper(
              onIndexChanged: _onIndexChanged, // 여기에 콜백 추가
              itemCount: celebrityquizData[widget.category]!.length,
              control: const SwiperControl(),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: containerSize,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_currentStep 단계',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1, // 1:1 비율
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Transform.scale(
                              alignment: Alignment.center,
                              scale: _scale,
                              child: Image.asset(
                                'assets/images/persongame/${widget.category}/${celebrityquizData[widget.category]![_currentIndex].values.first}.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_answer != null)
                          Text(_answer!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HamChorong',
                              ))
                        else // 정답 텍스트를 조건부로 표시합니다.
                          ElevatedButton(
                            onPressed: _showAnswer,
                            child: const Text('정답 확인하기'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 80, // 원하는 너비 설정
                height: 80, // 원하는 높이 설정
                child: FloatingActionButton(
                  heroTag: 'zoomIn', // heroTag는 Unique 해야 하므로 String으로 변경했습니다.
                  onPressed: _zoomIn,
                  // FloatingActionButton의 기본 색상 설정
                  backgroundColor: Colors.white,
                  child: Icon(Icons.zoom_in, size: 40, color: primaryColor),
                ),
              ),
              SizedBox(
                width: 80, // 원하는 너비 설정
                height: 80, // 원하는 높이 설정
                child: FloatingActionButton(
                  heroTag: 'zoomOut', // heroTag는 Unique 해야 하므로 String으로 변경했습니다.
                  onPressed: _zoomOut,
                  // FloatingActionButton의 기본 색상 설정
                  backgroundColor: Colors.white,
                  child: Icon(Icons.zoom_out, size: 40, color: primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showRewardFullBanner(BuildContext context, Function callback) async {
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
}

// 랜덤하게 나오게도 해야하ㅣㅁ
// 봤던 애 또나오게 하면 안됨 그리고 다 보면 리셋 관련한 카드 나와서 리셋하게끔(광고) 줌인 줌아웃, 스피드인물퀴즈는 서로 같은 필드를 공유해야함
// 아이돌, 배우, 개그맨 등을 선택하게끔 하는 UI 필요. (줌인 줌아웃, 스피드인물퀴즈는 서로 같은 필드를 공유해야함)

