import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/celebrityquiz_data.dart';
import '../../widgets/custom_snackbar.dart';

class ZoomInScreen extends StatefulWidget {
  final String category; // actor | idol | comedian
  const ZoomInScreen({super.key, required this.category});

  @override
  _ZoomInScreenState createState() => _ZoomInScreenState();
}

class _ZoomInScreenState extends State<ZoomInScreen> {
  final double _initialScale = 0.05; // 초기 확대 비율을 나타내는 상수
  late double _scale; // 현재 확대 비율
  final List<double> _scaleHistory = []; // 줌 레벨의 이력을 저장하는 스택
  int _currentStep = 1; // 현재 단계
  final int _maxStep = 20; // 최대 단계
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

  @override
  void dispose() {
    super.dispose();
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
    setState(() {
      _answer = _filteredCelebrityList[_currentIndex].keys.first;
    });
  }

  void _zoomIn() {
    // If we haven't reached the maximum number of steps, zoom in
    if (_currentStep < _maxStep) {
      _scaleHistory.add(_scale); // Save the current scale to history
      setState(() {
        _scale = ((_scale + 0.05) <= 1.0)
            ? _scale + 0.05
            : 1.0; // Increment scale, but don't exceed 1.0
        _currentStep++; // Increment current step
      });
    }
  }

  void _zoomOut() {
    // If there is history and we're not at the first step, zoom out
    if (_scaleHistory.isNotEmpty && _currentStep > 1) {
      setState(() {
        _scale =
            _scaleHistory.removeLast(); // Revert to the last scale from history
        _currentStep--; // Decrement current step
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

      showCustomSnackBar(
        context,
        "초기화가 완료되었습니다.",
        isSuccess: true,
      );
    } catch (e) {
      showCustomSnackBar(
        context,
        "초기화에 실패했습니다. 다시 시도해주세요.",
        isSuccess: false,
      );
    }
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
              height: MediaQuery.of(context).size.height *
                  (MediaQuery.of(context).size.width > 768 ? 0.8 : 0.75),
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
                              WidgetStateProperty.all(primaryColor),
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
              height: MediaQuery.of(context).size.height *
                  (MediaQuery.of(context).size.width > 768 ? 0.8 : 0.75),
              child: Swiper(
                onIndexChanged: _onIndexChanged,
                itemCount: _filteredCelebrityList.length + 1,
                control: const SwiperControl(),
                controller: _swiperController, // SwiperController 할당
                itemBuilder: (BuildContext context, int index) {
                  if (index == _filteredCelebrityList.length) {
                    // 여기서 '모든 이미지를 보셨습니다.' 카드를 반환합니다.
                    return SizedBox(
                      height: MediaQuery.of(context).size.height *
                          (MediaQuery.of(context).size.width > 768
                              ? 0.8
                              : 0.75),
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
                                      WidgetStateProperty.all(primaryColor),
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
                                    WidgetStateProperty.all(primaryColor),
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
                  heroTag: 'zoomOut', // heroTag는 Unique 해야 하므로 String으로 변경했습니다.
                  onPressed: _zoomOut,
                  // FloatingActionButton의 기본 색상 설정
                  backgroundColor: Colors.white,
                  child: Icon(Icons.zoom_out, size: 40, color: primaryColor),
                ),
              ),
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
            ],
          ),
        ],
      ),
    );
  }
}
