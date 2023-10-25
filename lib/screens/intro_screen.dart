import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    _buildPage("중간중간 게임이 포함되어 있습니다.", "세팅 창에서 게임을 끌 수 있습니다.",
        "assets/images/category-image.png"),
    _buildPage("다양한 카테고리를 선택해주세요.", "위아래로 스와이핑 형식으로 질문을 확인할 수 있습니다.",
        "assets/images/gamecard-image.png"),
    _buildPage("3초이상 질문을 보면 그 질문은 다시 나오지 않습니다.", "세팅 값에 들어가서 초기화하면 됩니다.",
        "assets/images/questioncard-image.png"),
  ];

  _setIntroShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('introShown', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFF0),
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          return _pages[index];
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _currentPage == 0
                    ? null
                    : () {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
              ),
              if (_currentPage == _pages.length - 1)
                ElevatedButton(
                  child: const Text("시작하기!"),
                  onPressed: () {
                    _setIntroShown();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                )
              else
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      width: 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.green
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _currentPage == _pages.length - 1
                    ? null
                    : () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPage(String title, String description, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 동그란 원 안에 이미지 넣기
        Container(
          width: 300.0,
          height: 300.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5.0),
          ),
          child: CircleAvatar(
            radius: 70.0,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff2f2f2f),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ],
    );
  }
}
