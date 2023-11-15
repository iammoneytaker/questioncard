import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeedQuizScreen extends StatefulWidget {
  final String category;
  const SpeedQuizScreen({Key? key, required this.category}) : super(key: key);

  @override
  _SpeedQuizScreenState createState() => _SpeedQuizScreenState();
}

const Color primaryColor = Color(0xffF5988D);

class _SpeedQuizScreenState extends State<SpeedQuizScreen> {
  Timer? _timer;
  final int _currentIndex = 0;
  bool _isStarted = false;
  bool _isCountdownVisible = false;
  int _timeLeft = 3;
  final List<Map<String, String>> _filteredCelebrityList = [];
  bool isLoading = true;

  final Color backgroundColor = const Color(0xfffffff0);
  bool _showCardWidget = false; // Add this new state variable

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadFilteredCelebrityList();
  }

  Future<void> _loadFilteredCelebrityList() async {
    // Load and filter the celebrity list based on saved data
    setState(() => isLoading = false);
  }

  void _startQuiz() {
    setState(() {
      _isStarted = true;
      _isCountdownVisible = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 3;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        setState(() {
          _isCountdownVisible = false;
        });
        _showCard();
      }
    });
  }

  void _showCard() {
    setState(() {
      _showCardWidget = true; // Show the card widget
    });

    // Hide the card after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // _showCardWidget = false; // Hide the card widget
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSize = screenWidth * 0.9;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Speed Quiz'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.center,
              children: [
                if (!_isStarted)
                  Center(
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                      ),
                      child: const Text('Start!'),
                    ),
                  ),
                if (_isCountdownVisible)
                  CountdownAnimation(
                    key: UniqueKey(),
                    countdownStart: _timeLeft,
                  ),
                // New card widget that will be displayed after countdown
                if (_showCardWidget)
                  Center(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        width: cardSize,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/persongame/actor/aiyu.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '2',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // The rest of your PageView.builder and other widgets...
                // Add your buttons for 'Check Answer' and 'Next' here
              ],
            ),
    );
  }
}

class CountdownAnimation extends StatefulWidget {
  final int countdownStart;

  const CountdownAnimation({
    Key? key,
    required this.countdownStart,
  }) : super(key: key);

  @override
  State<CountdownAnimation> createState() => _CountdownAnimationState();
}

class _CountdownAnimationState extends State<CountdownAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _countdownTime;

  @override
  void initState() {
    super.initState();
    _countdownTime = widget.countdownStart;
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_countdownTime > 1) {
            setState(() {
              _countdownTime--;
            });
            _controller.reset(); // Instead of reverse, reset the controller
          } else {
            // Do not dispose the controller here
          }
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Ensure the controller is disposed here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_countdownTime',
                style: TextStyle(
                  fontSize: 150 * _animation.value,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
