import 'dart:math';

import 'package:flutter/material.dart';

class RouletteWidget extends StatefulWidget {
  const RouletteWidget({super.key});

  @override
  _RouletteWidgetState createState() => _RouletteWidgetState();
}

class _RouletteWidgetState extends State<RouletteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _angle = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1), // 여기서 애니메이션의 속도를 조절합니다. 1초로 변경했습니다.
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 원
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xfffffff0),
                border: Border.all(color: const Color(0xffF5988D), width: 3),
              ),
            ),
            // 중앙의 점
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffF5988D),
              ),
            ),
            // 화살표
            Transform.rotate(
              angle: _angle,
              child: CustomPaint(
                painter: ArrowPainter(),
                child: const SizedBox(
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  final random = Random();
                  final rotations = 5 + random.nextDouble();
                  final randomAngle =
                      2 * pi * random.nextDouble(); // 0부터 360도 사이의 랜덤한 각도
                  final endAngle = _angle +
                      rotations * 2 * pi +
                      randomAngle; // 현재 각도에 랜덤한 각도를 추가

                  _animation = Tween<double>(begin: _angle, end: endAngle)
                      .animate(_controller)
                    ..addListener(() {
                      setState(() {
                        _angle = _animation.value;
                      });
                    })
                    ..addStatusListener((status) {
                      if (status == AnimationStatus.completed) {
                        // _controller.reset();
                      }
                    });

                  _controller.forward(from: 0);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xffF5988D), // 글씨색
                  shadowColor: Colors.black45, // 그림자 색
                  elevation: 5, // 그림자 높이
                ),
                child: const Text("돌리기")),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xff2f2f2f), // 글씨색
                shadowColor: Colors.black45, // 그림자 색
                elevation: 5, // 그림자 높이
              ),
              child: const Text("닫기"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xffF5988D)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double arrowLength = 20;
    const double arrowWidth = 10;

    // 화살표의 선
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, 0),
      paint,
    );

    // 화살표의 머리 부분
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2 - arrowWidth / 2, arrowLength),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2 + arrowWidth / 2, arrowLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
