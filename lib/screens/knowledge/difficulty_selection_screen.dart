import 'package:flutter/material.dart';
import 'general_knowledge_quiz_screen.dart';

const Color primaryColor = Color(0xffF5988D);
const Color backgroundColor = Color(0xfffffff0);

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('난이도 선택'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDifficultyButton(context, '중학생'),
            const SizedBox(height: 20),
            _buildDifficultyButton(context, '고등학생'),
            const SizedBox(height: 20),
            _buildDifficultyButton(context, '성인'),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String difficulty) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GeneralKnowledgeQuizScreen(difficulty: difficulty),
          ),
        );
      },
      child: Text(
        difficulty,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
