import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';
import 'package:questioncard/data/ad_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/category_data.dart';
import '../models/category.dart';
import '../widgets/custom_snackbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isGameSettingOn = true; // 게임 설정 ON/OFF 상태를 저장하는 변수
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _loadGameSetting();
  }

  // 게임 설정을 불러오는 함수
  _loadGameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGameSettingOn = prefs.getBool('game_setting') ?? true;
    });
  }

  // 게임 설정을 저장하는 함수
  _saveGameSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('game_setting', value);
  }

  void _resetAllViewedQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 모든 카테고리에 대한 봤던 질문들의 데이터를 초기화
    for (Category category in categories) {
      await prefs.remove(category.categoryCode);
    }

    // 사용자에게 알림 표시
    showCustomSnackBar(context, "모든 질문을 초기화했습니다.", isSuccess: true);
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('확인'),
          content: const Text('정말로 모든 질문을 초기화하시겠습니까?\n(이전에 확인한 질문이 다시 나옵니다.)'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                // 로딩 다이얼로그 표시
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
                          Text("광고 로드 중 입니다.. 잠시만 기다려주세요..(🥹)"),
                        ],
                      ),
                    );
                  },
                );

                showRewardFullBanner(context, () async {
                  Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
                  Navigator.of(context).pop(); // 초기화 다이얼로그 닫기

                  try {
                    _resetAllViewedQuestions(); // 모든 질문 초기화
                  } catch (e) {
                    showCustomSnackBar(
                      context,
                      "초기화에 실패했습니다.",
                      isSuccess: false,
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangeGameStaetDialog(bool value) {
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
              Text("광고 로드 중 입니다.. 잠시만 기다려주세요..(🥹)"),
            ],
          ),
        );
      },
    );

    showRewardFullBanner(context, () async {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      try {
        setState(() {
          _isGameSettingOn = value;
        });
        _saveGameSetting(value); // 게임 설정 저장
      } catch (e) {
        showCustomSnackBar(
          context,
          '상태 변경에 실패했습니다.',
          isSuccess: false,
        );
      }
    });
  }

  void _sendEmail() async {
    // 앱 정보 가져오기
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    // 기기 정보 가져오기
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String os = "";
    String deviceDetails = "";

    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      os = "Android";
      deviceDetails = "${androidInfo.manufacturer} ${androidInfo.model}";
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      os = "iOS";
      deviceDetails = "${iosInfo.name} ${iosInfo.systemVersion}";
    }

    final Uri emailLaunchUri =
        Uri(scheme: 'mailto', path: 'sangwon2618@google.com', queryParameters: {
      'subject': '어색할때 앱 문의',
      'body':
          '앱 버전: $version\n운영체제: $os\n기기: $deviceDetails\n\n[문의 내용을 여기에 작성해주세요.]'
    });

    // 이메일 앱 열기
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      _showEmailErrorDialog();
      print('Could not launch $emailLaunchUri');
    }
  }

  void _showEmailErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text(
            '메일앱을 불러오는데에 실패했습니다.\n잠시후에 시도해주세요.\n아니면 아래 이메일로 연락부탁드립니다.\nsangwon2618@gmail.com',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '이메일 복사',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.lightBlue),
              ),
              onPressed: () {
                Clipboard.setData(
                        const ClipboardData(text: 'sangwon2618@gmail.com'))
                    .then((result) {
                  Navigator.of(context).pop(); // 대화상자 닫기
                  showCustomSnackBar(context, "이메일이 복사되었습니다.", isSuccess: true);
                });
              },
            ),
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
            ),
          ],
        );
      },
    );
  }

  void _clickOepnKakao() {
    launchUrl(
      Uri.parse('https://open.kakao.com/o/gzNYJEOf'),
    );
  }

  void _requestReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      showCustomSnackBar(
        context,
        '불러오기에 실패했습니다. 잠시뒤에 다시 시도해주세요',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '앱 기능',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('현재까지 확인한 질문 초기화'),
          onTap: _showResetConfirmationDialog,
          trailing: const Icon(Icons.refresh),
        ),
        const Divider(), // 구분선 추가
        SwitchListTile(
          title: const Text('질문카드에 게임카드 나오게하기'),
          value: _isGameSettingOn,
          onChanged: (bool value) {
            _showChangeGameStaetDialog(value);
          },
        ),
        const Divider(), // 구분선 추가
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '앱 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('앱 문의하기'),
          onTap: _sendEmail,
          trailing: const Icon(Icons.mail),
        ),
        const Divider(), // 구분선 추가
        ListTile(
          title: const Text('앱 리뷰'),
          onTap: _requestReview,
          trailing: const Icon(Icons.star),
        ),
        const Divider(), // 구분선 추가
        ListTile(
          title: const Text('오픈카톡 참여'),
          onTap: _clickOepnKakao,
          trailing: const Icon(Icons.launch),
        ),
        const Divider(), // 구분선 추가
      ],
    );
  }

  void showRewardFullBanner(BuildContext context, Function callback) async {
    await RewardedInterstitialAd.load(
      adUnitId: REWARD_INTERSTRITIAL_ADID,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback:
          RewardedInterstitialAdLoadCallback(onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
            print('1');
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent:
              (RewardedInterstitialAd ad, AdError error) {
            print('2');
            ad.dispose();
          },
        );

        ad.show(onUserEarnedReward: (ad, reward) {
          print('3');
          callback(); // 광고 시청 보상 후 초기화 콜백 호출
        });
      }, onAdFailedToLoad: (_) {
        print(_);
        callback(); // 광고 로드 실패 시 초기화 콜백 호출
      }),
    );
  }
}
