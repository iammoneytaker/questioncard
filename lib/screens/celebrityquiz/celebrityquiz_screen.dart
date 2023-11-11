import 'package:flutter/material.dart';

class CelebrityQuiz extends StatefulWidget {
  const CelebrityQuiz({super.key});

  @override
  _CelebrityQuizState createState() => _CelebrityQuizState();
}

class _CelebrityQuizState extends State<CelebrityQuiz> {
  double _scale = 1.0; // 이미지의 초기 스케일

  void _zoomOut() {
    setState(() {
      _scale = (_scale - 0.1).clamp(0.5, 1.0); // 최소 0.5, 최대 1.0 범위로 제한
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연예인 인물 퀴즈'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform.scale(
              scale: _scale,
              child: Image.asset('assets/images/강호동.png'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _zoomOut,
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
