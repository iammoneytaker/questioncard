import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
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
                _resetAllViewedQuestions(); // 모든 질문 초기화
                Navigator.of(context).pop(); // 대화상자 닫기
              },
            ),
          ],
        );
      },
    );
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
      print('Could not launch $emailLaunchUri');
    }
  }

  void _clickOepnKakao() {
    launchUrl(
      Uri.parse('https://open.kakao.com/o/gzNYJEOf'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('현재까지 확인한 질문 초기화'),
          onTap: _showResetConfirmationDialog,
        ),
        ListTile(
          leading: const Icon(Icons.mail),
          title: const Text('앱 문의하기'),
          onTap: _sendEmail,
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title: const Text('앱 리뷰'),
          onTap: () {
            // TODO: 앱 리뷰 로직 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: const Text('오픈카톡 참여'),
          onTap: _clickOepnKakao,
        ),
        SwitchListTile(
          title: const Text('질문카드에 게임 나오게하기'),
          value: _isGameSettingOn,
          onChanged: (bool value) {
            setState(() {
              _isGameSettingOn = value;
            });
            _saveGameSetting(value); // 게임 설정 저장
          },
        ),
      ],
    );
  }
}
