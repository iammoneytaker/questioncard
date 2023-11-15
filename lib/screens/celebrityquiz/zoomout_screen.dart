import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/ad_data.dart';
import '../../data/celebrityquiz_data.dart';
import '../../widgets/custom_snackbar.dart';

class ZoomOutScreen extends StatefulWidget {
  final String category; // actor | idol | comedian
  const ZoomOutScreen({super.key, required this.category});

  @override
  _ZoomOutScreenState createState() => _ZoomOutScreenState();
}

class _ZoomOutScreenState extends State<ZoomOutScreen> {
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

  // SharedPreferences 인스턴스를 가져오는 메서드
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Map<String, String>> _filteredCelebrityList = []; // 필터링된 연예인 리스트
  // isLoading 상태 변수 추가
  bool isLoading = true;
  final bool _allImagesViewed = false;

  @override
  void initState() {
    super.initState();
    _scale = _initialScale;
    _loadFilteredCelebrityList().then((_) {
      // 필터링된 리스트 로딩 후 첫 번째 아이템 처리
      if (_filteredCelebrityList.isNotEmpty) {
        _recordViewedCelebrityAfterDelay(
            _filteredCelebrityList.first.keys.first);
      }
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

  // Asynchronous method to load and filter the list
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

  void _showAnswer() {
    print(_currentIndex);
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
                child: Text(
                  "광고 로드 중 입니다..\n잠시만 기다려주세요..",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );

    RewardedInterstitialAd.load(
      adUnitId: REWARD_INTERSTRITIAL_ADID,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
              print('Ad dismissed.');
              ad.dispose();
              Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
              // 보상을 받지 않았으므로 여기서는 정답을 보여주지 않음
              showCustomSnackBar(
                context,
                "광고 시청을 완료하지 않아 보상을 받지 못했습니다.",
                isSuccess: false,
              );
            },
            onAdFailedToShowFullScreenContent:
                (RewardedInterstitialAd ad, AdError error) {
              print('Ad failed to show.');
              ad.dispose();
              Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
              showCustomSnackBar(
                context,
                "광고를 보여주는데 실패했습니다.",
                isSuccess: false,
              );
            },
          );

          ad.show(onUserEarnedReward: (ad, reward) {
            ad.dispose();
            Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
            setState(() {
              _answer = _filteredCelebrityList[_currentIndex].keys.first;
            });
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load: $error');
          Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
          showCustomSnackBar(
            context,
            "광고를 로드하는데 실패했습니다.",
            isSuccess: false,
          );
        },
      ),
    );
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

  void _onIndexChanged(int index) {
    if (index == _filteredCelebrityList.length) {
      // 마지막 스와이프에서 '모든 이미지를 보셨습니다.' 카드를 보여준다고 가정하고
      // 아무 작업도 하지 않습니다.
      return;
    }
    // 기본 인덱스 변경 처리
    setState(() {
      _currentIndex = index; // 새로운 인덱스로 업데이트
      _scale = _initialScale; // 스케일을 초기 값으로 재설정
      _scaleHistory.clear(); // 줌 이력을 클리어
      _currentStep = 1; // 현재 단계를 초기화
      _answer = null;
    });
    // 지연된 시간 후에 연예인을 기록합니다.
    _recordViewedCelebrityAfterDelay(_filteredCelebrityList[index].keys.first);
  }

  void _recordViewedCelebrityAfterDelay(String celebrityName) {
    Future.delayed(const Duration(seconds: 1), () {
      _saveViewedCelebrity(widget.category, celebrityName);
    });
  }

  // 데이터 초기화~
  Future<void> _resetViewedCelebrities() async {
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
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      try {
        final SharedPreferences prefs = await _prefs;
        await prefs.setString(
            'celebrityData', json.encode({widget.category: []}));
        await _loadFilteredCelebrityList(); // Reload the filtered list

        setState(() {
          // Reset the swiper and other related variables
          _swiperController.move(0);
          _currentIndex = 0;
          _scale = _initialScale;
          _scaleHistory.clear();
          _currentStep = 1;
          _answer = null;
        });
      } catch (e) {
        showCustomSnackBar(
          context,
          "초기화에 실패했습니다. 다시 시도해주세요.",
          isSuccess: false,
        );
      }
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
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredCelebrityList.isEmpty)
            // 필터링된 리스트가 비어있을 경우 리셋 버튼을 표시합니다.
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: containerSize,
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
          else
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Swiper(
                onIndexChanged: _onIndexChanged,
                itemCount: _filteredCelebrityList.length + 1,
                control: const SwiperControl(),
                controller: _swiperController, // SwiperController 할당
                itemBuilder: (BuildContext context, int index) {
                  if (index == _filteredCelebrityList.length) {
                    // 여기서 '모든 이미지를 보셨습니다.' 카드를 반환합니다.
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: containerSize,
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
                    );
                  }
                  final celebrity = _filteredCelebrityList[index];
                  final celebrityName = celebrity.keys.first;
                  final celebrityFileName = celebrity.values.first;
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
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Transform.scale(
                                alignment: Alignment.center,
                                scale: _scale,
                                child: Image.asset(
                                  'assets/images/persongame/${widget.category}/$celebrityFileName.png',
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
                          else
                            ElevatedButton(
                              onPressed: () {
                                _showAnswer();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor),
                              ),
                              child: const Text(
                                '정답 확인하기',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
