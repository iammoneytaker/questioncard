import 'package:flutter/material.dart';
import 'package:questioncard/services/firebase_storage_service.dart';

class CelebrityQuizScreen extends StatefulWidget {
  const CelebrityQuizScreen({super.key});

  @override
  _CelebrityQuizScreenState createState() => _CelebrityQuizScreenState();
}

class _CelebrityQuizScreenState extends State<CelebrityQuizScreen> {
  double _scale = 10.0; // 초기 확대 비율
  final List<double> _scaleHistory = []; // 줌 레벨의 이력을 저장하는 스택
  int _currentStep = 1; // 현재 단계
  final int _maxStep = 10; // 최대 단계

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
    _loadCelebrity(); // 비동기 함수 호출
  }

  Future<void> _loadCelebrity() async {
    try {
      final celebrityList = await ApiService().getCelebrityList();
      print(celebrityList);
      // TODO: 여기에서 추가적인 상태 업데이트 로직을 구현합니다.
    } catch (e) {
      print('Error loading celebrity list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerSize = screenWidth * 0.8; // 화면 너비의 80% 크기

    return Scaffold(
      appBar: AppBar(
        title: const Text('연예인 퀴즈'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              '$_currentStep 단계',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: _zoomOut,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Transform.scale(
                    scale: _scale,
                    alignment: Alignment.center,
                    child:
                        Image.asset('assets/images/강호동.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // 버튼과의 간격
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _zoomIn,
                child: const Text('이전 단계'),
              ),
              ElevatedButton(
                onPressed: _zoomOut,
                child: const Text('다음 단계'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
