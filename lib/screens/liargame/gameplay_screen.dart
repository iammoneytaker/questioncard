import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/ad_data.dart';
import '../../data/category_data.dart';
import '../../models/category.dart';
import '../../providers/gamesetting.dart';

class GamePlayScreen extends StatefulWidget {
  final GameSettings gameSettings;
  final String categoryName;
  final String categoryCode;
  const GamePlayScreen({
    Key? key,
    required this.gameSettings,
    required this.categoryName,
    required this.categoryCode,
  }) : super(key: key);

  @override
  _GamePlayScreenState createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final Color backgroundColor = const Color(0xfffffff0);
  final Color appBarColor = const Color(0xff375A7F); // AppBar 색상 변경

  // TODO: 광고 중간에 동영상 닫기 버튼 누르면 광고 로드 중입니다 라는 팝업이 계속 뜨는 이슈가 있음.

  List<String> words = [];
  List<String> playedWords = [];
  int currentPlayer = 0;
  String currentWord = '';
  bool gameEnded = false;

  List<int> liars = []; // 라이어의 인덱스를 저장할 리스트
  String sharedWord = ''; // 모든 참가자가 공유할 단어
  String uniqueWordForLiar = ''; // 바보 모드 라이어만의 단어.

  Timer? _timer; // 타이머를 위한 변수
  bool isPressing = false; // 사용자가 카드를 누르고 있는지 여부
  Timer? _pressTimer; // 사용자가 누르고 있는 시간을 추적하기 위한 타이머

  // AD
  bool _isBannerAdReady = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    initializeGame();
    _loadBannerAd();
  }

  Future<void> initializeGame() async {
    // 카테고리 코드에 해당하는 단어들을 가져옵니다.
    words = getWordsForCategory(widget.categoryCode);
    // 이전에 플레이한 단어들을 불러옵니다.
    playedWords = await loadPlayedWords();
    // 필터링된 단어 리스트를 가져옵니다.
    words = await getFilteredWords(widget.categoryCode, words);
    // 라이어를 할당합니다.
    assignLiars();
    // 공유할 단어를 선택합니다.
    sharedWord = await selectSharedWord();

    // 바보모드일 경우에만 uniqueWordForLiar를 설정합니다.
    if (widget.gameSettings.mode == '바보모드') {
      setUniqueWordForLiar();
    }
  }

// 바보모드일 때 사용할 uniqueWordForLiar를 설정하는 함수
  void setUniqueWordForLiar() {
    List<String> filteredWords = getWordsForCategory(widget.categoryCode)
        .where((word) => word != sharedWord)
        .toList()
      ..shuffle();
    setState(() {
      uniqueWordForLiar = filteredWords.first;
    });
  }

  List<String> getWordsForCategory(String categoryCode) {
    // liargameCategories에서 해당 카테고리 코드의 단어 리스트를 찾습니다.
    final category = liargameCategories.firstWhere(
      (category) => category.categoryCode == categoryCode,
      orElse: () => LiarCategory(name: 'None', categoryCode: '000', words: []),
    );
    return category.words;
  }

  void assignLiars() {
    final random = Random();
    // 라이어의 수만큼 랜덤 인덱스를 생성하여 liars 리스트에 추가
    while (liars.length < widget.gameSettings.numberOfLiars) {
      int liarIndex = random.nextInt(widget.gameSettings.numberOfPlayers);
      if (!liars.contains(liarIndex)) {
        liars.add(liarIndex);
      }
    }
  }

  // 이전에 플레이한 단어들을 불러오는 함수
  Future<List<String>> loadPlayedWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(widget.categoryCode) ?? [];
  }

  Future<List<String>> getFilteredWords(
      String categoryCode, List<String> allWords) async {
    final playedWords = await loadPlayedWords();
    return allWords.where((word) => !playedWords.contains(word)).toList();
  }

  Future<void> saveWordsToSharedPreferences(
      String categoryCode, List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(categoryCode, words);
  }

  void showWord() {
    // 단어를 보여주는 로직
    setState(() {
      isPressing = true;
    });
  }

  void hideWordAndNextPlayer() {
    // 단어를 숨기고 다음 플레이어로 넘어가는 로직
    setState(() {
      isPressing = false;
      nextPlayer();
    });
  }

  void onCardPressed() {
    if (gameEnded) return;
    // 카드를 눌렀을 때 실행되는 로직
    _pressTimer = Timer(const Duration(milliseconds: 400), showWord);
  }

  void onCardReleased() {
    // 카드에서 손을 뗐을 때 실행되는 로직
    _pressTimer?.cancel(); // 타이머가 있다면 취소
  }

  void onCardTapped() {
    // 카드를 탭했을 때 실행되는 로직
    if (isPressing) {
      // 단어가 보여지고 있는 상태에서 카드를 탭하면 다음 플레이어로 넘어감
      hideWordAndNextPlayer();
    }
  }

  void startGame() {
    // 게임 시작 로직
    setState(() {
      isPressing = true; // 사용자가 카드를 누르고 있음을 나타냄
      _timer = Timer(const Duration(milliseconds: 400), () {
        // 2초 후에 실행될 로직
        setState(() {
          isPressing = false; // 2초가 지나면 누르고 있지 않은 상태로 변경
        });
      });
    });
  }

  void nextPlayer() {
    // 다음 플레이어로 넘어가는 로직
    _timer?.cancel(); // 이전 타이머가 있다면 취소
    if (currentPlayer < widget.gameSettings.numberOfPlayers - 1) {
      setState(() {
        currentPlayer++;
        isPressing = false; // 다음 플레이어로 넘어갈 때는 누르고 있지 않은 상태로 변경
      });
    } else {
      endGame();
    }
  }

  void endGame() {
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
                  "광고 로드 중 입니다..\n게임하는동안만 봐줘요잉(🥹)",
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
        setState(() {
          gameEnded = true;
        });
      } catch (e) {
        setState(() {
          gameEnded = true;
        });
      }
    });
  }

  void revealLiar() {
    // 라이어를 공개하는 로직
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('라이어 공개'),
          content: Text('라이어는 ${liars.map((i) => i + 1).join(", ")}번 플레이어입니다.'),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(appBarColor),
              ),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> selectSharedWord() async {
    if (words.isNotEmpty) {
      final selectedWord = words[Random().nextInt(words.length)];
      savePlayedWord(selectedWord);
      return selectedWord;
    } else {
      // 모든 단어가 사용되었다면 기존에 사용한 단어들을 리셋합니다.
      await resetPlayedWords();
      // 리셋 후 첫 번째 단어를 선택합니다.
      final selectedWord = words[0];
      return selectedWord;
    }
  }

  Future<void> resetPlayedWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(widget.categoryCode, []);
    setState(() {
      words = getWordsForCategory(widget.categoryCode);
      playedWords = [];
    });
  }

  Future<void> savePlayedWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final newPlayedWords = List<String>.from(playedWords)..add(word);
    await prefs.setStringList(widget.categoryCode, newPlayedWords);
    setState(() {
      playedWords = newPlayedWords;
    });
  }

  _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: BANNER_ADID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (Ad ad) {
        print('$ad loaded.');
        setState(() {
          _isBannerAdReady = true;
        });
      }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('$ad failed to load: $error');
        ad.dispose();
        setState(() {
          _isBannerAdReady = false;
        });
      }, onAdClosed: (Ad ad) {
        setState(() {
          _isBannerAdReady = false;
        });
      }),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pressTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black87,
        title: Text(widget.categoryName),
      ),
      body: Stack(children: [
        Container(
          color: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
            child: Center(
              child: GestureDetector(
                onLongPressStart: (_) => onCardPressed(), // 길게 누르기 시작할 때
                onLongPressEnd: (_) => onCardReleased(), // 길게 누르기를 놓았을 때
                onTap: onCardTapped, // 카드를 탭했을 때
                child: SizedBox(
                  width: double.infinity, // 최대 너비
                  height: double.infinity, // 최대 높이
                  child: Card(
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 세로 축 중앙 정렬
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 가로 축 중앙 정렬
                        children: [
                          if (isPressing) ...[
                            // 사용자가 카드를 누르고 있을 때 보여줄 내용
                            if (liars.contains(currentPlayer) &&
                                widget.gameSettings.mode == '노멀모드') ...[
                              // 라이어일 경우 이미지를 표시
                              Image.asset('assets/images/liargame.png'),
                              const SizedBox(height: 20),
                              const Text(
                                '당신은 라이어입니다',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HamChorong',
                                ),
                              ),
                            ] else ...[
                              if (widget.gameSettings.mode == '노멀모드')
                                // 라이어가 아닐 경우 단어를 표시
                                Text(
                                  sharedWord,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'HamChorong',
                                  ),
                                ),
                              if (widget.gameSettings.mode == '바보모드')
                                Text(
                                  liars.contains(currentPlayer)
                                      ? uniqueWordForLiar
                                      : sharedWord,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'HamChorong',
                                  ),
                                )
                            ],
                            const SizedBox(height: 20),
                            const Text(
                              '확인하셨으면 터치 후 \n다음사람에게 넘겨주세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.0,
                                height: 1.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HamChorong',
                              ),
                            ),
                          ] else if (!gameEnded) ...[
                            // 게임이 끝나지 않았을 때 보여줄 내용
                            Text(
                              '${currentPlayer + 1}번님!! 단어를 보시려면\n카드를\n2초이상 꾹 눌러주세요!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20.0,
                                height: 1.5,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HamChorong',
                              ),
                            ),
                          ] else ...[
                            // 게임이 종료되었을 때 보여줄 내용
                            const Text(
                              '완료되었습니다.\n라이어를 찾아주세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28.0,
                                height: 1.5,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HamChorong',
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black87),
                              ),
                              onPressed: revealLiar,
                              child: const Text('라이어 확인하기'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isBannerAdReady)
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.1,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
      ]),
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
