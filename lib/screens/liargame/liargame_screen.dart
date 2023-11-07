import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/category_data.dart';
import '../../providers/gamesetting.dart';
import 'gameplay_screen.dart';

class LiarGameScreen extends StatelessWidget {
  const LiarGameScreen({Key? key}) : super(key: key);
  final Color primaryColor = const Color(0xffF5988D); // AppBar 색상
  final Color cardBackgroundColor = const Color(0xff343541); // 카드 배경색
  final Color appBarColor = const Color(0xff375A7F); // AppBar 색상 변경

  // 라이어게임 카테고리별 데이터 구현 안되어 있음.
  // 라이어게임 카테고리별 데이터 가져와서 랜덤으로 보여주는 것 구현 안되어있음

  // TODO: 카테고리에 데이터만 꾸겨 넣으면 됌.
  // TODO: 인물퀴즈, 노래 맞추기

  @override
  Widget build(BuildContext context) {
    // 카테고리 리스트

    return Scaffold(
      backgroundColor: const Color(0xff2f2f2f), // 배경색
      appBar: AppBar(
        title: const Text(
          '라이어 게임',
          style: TextStyle(
            fontSize: 20.0, // AppBar 타이틀 크기 변경
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'HamChorong',
          ),
        ),
        backgroundColor: appBarColor, // AppBar 색상 변경
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: liargameCategories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(
            title: liargameCategories[index].name,
            onTap: () {
              _showGameStartDialog(context, liargameCategories[index].name,
                  liargameCategories[index].categoryCode);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardBackgroundColor, // 카드 배경색 변경
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20, // 텍스트 크기 변경
              color: Colors.white,
              fontFamily: 'HamChorong',
            ),
          ),
        ),
      ),
    );
  }

  void _showGameStartDialog(
      BuildContext context, String categoryName, String categoryCode) {
    var gameSettings = Provider.of<GameSettings>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), // 모달의 모서리를 둥글게
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내용물에 맞게 크기 조절
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      '게임을 시작하겠습니까?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HamChorong',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '선택한 카테고리: $categoryName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HamChorong',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '참여 인원: ${gameSettings.numberOfPlayers}명',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'HamChorong',
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(appBarColor),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                        textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 14,
                          fontFamily: 'HamChorong',
                        )),
                      ),
                      child: const Text('변경하기'),
                      onPressed: () {
                        _changeNumberOfPlayers(context, gameSettings);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '모드 선택: ${gameSettings.mode}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'HamChorong',
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(appBarColor),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                        textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 14,
                          fontFamily: 'HamChorong',
                        )),
                      ),
                      child: const Text('변경하기'),
                      onPressed: () {
                        _changeMode(context, gameSettings);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '라이어: ${gameSettings.numberOfLiars}명',
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'HamChorong',
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(appBarColor),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                        textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 14,
                          fontFamily: 'HamChorong',
                        )),
                      ),
                      child: const Text('변경하기'),
                      onPressed: () {
                        _changeNumberOfLiars(context, gameSettings);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, // 버튼을 모달의 너비에 맞게 설정
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(appBarColor),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                      textStyle: MaterialStateProperty.all(const TextStyle(
                        fontSize: 16,
                        fontFamily: 'HamChorong',
                      )),
                    ),
                    child: const Text('시작'),
                    onPressed: () {
                      var gameSettings =
                          Provider.of<GameSettings>(context, listen: false);

                      Navigator.pop(context); // 설정 화면을 닫습니다.
                      // 게임 설정 데이터를 새로운 화면으로 전달하면서 화면을 전환합니다.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePlayScreen(
                            gameSettings: gameSettings, // 게임 설정 데이터 전달
                            categoryName: categoryName, // 선택된 카테고리 이름 전달
                            categoryCode: categoryCode,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPicker(
    BuildContext context,
    List<int> options,
    String title,
    String subtitle,
    int selectedIndex,
    ValueChanged<int> onSelectedItemChanged,
    bool isChangeMode,
  ) {
    int tempSelectedIndex = selectedIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 모달이 전체 화면을 차지하도록 설정
      backgroundColor: Colors.transparent, // 모달의 배경을 투명하게 설정
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // 모달의 높이를 화면 높이의 50%로 설정
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.8, // 모달의 너비를 화면 너비의 70%로 설정
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15), // 모달의 모서리를 둥글게 설정
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 내용에 맞게 높이를 설정
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 8.0),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      magnification: 1.22,
                      backgroundColor: Colors.white,
                      itemExtent: 32.0, // 높이
                      onSelectedItemChanged: (int index) {
                        tempSelectedIndex = index;
                      },
                      scrollController: FixedExtentScrollController(
                          initialItem: selectedIndex),
                      children: isChangeMode
                          ? ['노멀모드', '바보모드']
                              .map((String value) => Text(value))
                              .toList()
                          : options
                              .map((int value) => Text('$value명'))
                              .toList(), // 기본 선택된 항목 지정
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('확인'),
                    onPressed: () {
                      onSelectedItemChanged(tempSelectedIndex);
                      Navigator.pop(context); // 모달을 닫습니다.
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _changeNumberOfPlayers(BuildContext context, GameSettings gameSettings) {
    // 현재 게임 설정에서 선택된 인원 수를 가져옵니다.
    int currentNumberOfPlayers = gameSettings.numberOfPlayers;

    // _showPicker를 호출하여 인원 수를 선택할 수 있게 합니다.
    _showPicker(
      context,
      List<int>.generate(20, (i) => i + 1), // 1부터 20까지의 숫자 생성
      '참여 인원 선택',
      '총 참여인원 수를 설정해주세요.',
      currentNumberOfPlayers - 1, // 0부터 시작하는 인덱스로 변환
      (int selectedIndex) {
        int newNumberOfPlayers = selectedIndex + 1;
        // 라이어 인원보다 참여 인원이 많은지 확인합니다.
        if (newNumberOfPlayers <= gameSettings.numberOfLiars) {
          // 에러 메시지를 표시합니다.
          print('?!!!');
          _showErrorDialog(context, '참여 인원은 라이어 인원보다 많아야 합니다.');
        } else {
          // 사용자가 새로운 인원 수를 선택했을 때 호출될 콜백
          gameSettings.setNumberOfPlayers(newNumberOfPlayers);
          // 상태 변경을 감지하여 UI를 업데이트합니다.
          (context as Element).markNeedsBuild();
        }
      },
      false,
    );
  }

  void _changeNumberOfLiars(BuildContext context, GameSettings gameSettings) {
    // 현재 게임 설정에서 선택된 인원 수를 가져옵니다.
    int currentNumberOfLiars = gameSettings.numberOfLiars;

    // _showPicker를 호출하여 인원 수를 선택할 수 있게 합니다.
    _showPicker(
      context,
      List<int>.generate(5, (i) => i + 1), // 1부터 20까지의 숫자 생성
      '라이어 인원 선택',
      '총 라이어 수를 설정해주세요.',
      currentNumberOfLiars - 1, // 0부터 시작하는 인덱스로 변환
      (int selectedIndex) {
        int newNumberOfLiars = selectedIndex + 1;
        // 라이어 인원보다 참여 인원이 많은지 확인합니다.
        if (newNumberOfLiars >= gameSettings.numberOfLiars) {
          // 에러 메시지를 표시합니다.
          _showErrorDialog(context, '라이어 인원은 참여 인원보다 작아야 합니다.');
        } else {
          // 사용자가 새로운 인원 수를 선택했을 때 호출될 콜백
          gameSettings.setNumberOfLiars(selectedIndex + 1);
          // 상태 변경을 감지하여 UI를 업데이트합니다.
          (context as Element).markNeedsBuild();
        }
      },
      false,
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _changeMode(BuildContext context, GameSettings gameSettings) {
    // 모드 이름을 담은 리스트
    List<String> modes = ['노멀모드', '바보모드'];

    // 현재 게임 설정에서 선택된 모드의 인덱스를 가져옵니다.
    int currentModeIndex = modes.indexOf(gameSettings.mode);

    // _showPicker를 호출하여 인원 수를 선택할 수 있게 합니다.
    _showPicker(
      context,
      List<int>.generate(modes.length, (i) => i),
      '모드 선택',
      '바보모드 - 라이어에게만 다른 단어 제공,\n노멀모드 - 라이어는 "라이어"라는 카드를 받음',
      currentModeIndex,
      (int selectedIndex) {
        // 사용자가 새로운 인원 수를 선택했을 때 호출될 콜백
        gameSettings.setMode(modes[selectedIndex]);
        // 상태 변경을 감지하여 UI를 업데이트합니다.
        (context as Element).markNeedsBuild();
      },
      true,
    );
  }
}
