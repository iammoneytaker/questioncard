import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('현재까지 확인한 질문 초기화'),
          onTap: () {
            // TODO: 질문 초기화 로직 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.mail),
          title: const Text('앱 문의하기'),
          onTap: () {
            // TODO: 앱 문의하기 로직 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title: const Text('앱 리뷰'),
          onTap: () {
            // TODO: 앱 리뷰 로직 구현
          },
        ),
        SwitchListTile(
          title: const Text('질문카드에 게임 설정'),
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
