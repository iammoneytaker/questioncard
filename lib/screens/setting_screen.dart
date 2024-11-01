import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';
import 'package:share_plus/share_plus.dart';
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllViewedQuestions();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangeGameStaetDialog(bool value) {
    try {
      setState(() {
        _isGameSettingOn = value;
      });
      _saveGameSetting(value);
    } catch (e) {
      showCustomSnackBar(
        context,
        '상태 변경에 실패했습니다.',
        isSuccess: false,
      );
    }
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
          '앱 버전: $version\n운영체제: $os\n기기: $deviceDetails\n\n[문의 을 여기에 작성해주세요.]'
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

  void _shareApp() {
    String message = '어색할때 앱을 사용해보세요!\n';
    if (Platform.isAndroid) {
      message += 'Android: [Play Store URL]\n';
    }
    if (Platform.isIOS) {
      message += 'iOS: [App Store URL]\n';
    }
    message += '함께 어색함을 깨보아요!';

    Share.share(message);
  }

  static const String _developerBlogUrl = 'https://withanalog.com/';

  Future<void> _launchDeveloperBlog() async {
    final Uri uri = Uri.parse(_developerBlogUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          showCustomSnackBar(context, '웹사이트를 열 수 없습니다.', isSuccess: false);
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, '웹사이트 연결 중 오류가 발생했습니다.', isSuccess: false);
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('앱 정보'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('이 앱은 현재 광고 없는 앱 100개 만들기 프로젝트의 일환으로 만들어졌습니다.'),
                SizedBox(height: 16),
                Text('어색할때 앱은 어색한 분위기를 재미있게 풀어갈 수 있는 엔터테인먼트 앱입니다.'),
                SizedBox(height: 16),
                Text(
                    '개인정보 보호: 사용자의 데이터는 오직 기기 내부에만 저장됩니다. 앱의 성과를 측정하기 위해 페이지 활성화 정보를 수집합니다.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _launchPrivacyPolicy() async {
    const url = 'https://doyak0315.tistory.com/52';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showCustomSnackBar(context, '웹사이트를 열 수 없습니다.', isSuccess: false);
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
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('앱 공유하기'),
          onTap: _shareApp,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.web),
          title: const Text('개발자 이야기 보러가기'),
          onTap: _launchDeveloperBlog,
        ),
        const Divider(),
        ListTile(
          title: const Text('앱 정보'),
          trailing: const Icon(Icons.info_outline),
          onTap: () => _showInfoDialog(context),
        ),
        ListTile(
          title: const Text('개인정보 처리방침'),
          trailing: const Icon(Icons.privacy_tip_outlined),
          onTap: _launchPrivacyPolicy,
        ),
        const Divider(), // 구분선 추가
      ],
    );
  }
}
