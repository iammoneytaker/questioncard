import 'package:flutter/foundation.dart';

class GameSettings with ChangeNotifier {
  int _numberOfPlayers = 4;
  int _numberOfLiars = 1;
  String _mode = '노멀모드';

  int get numberOfPlayers => _numberOfPlayers;
  int get numberOfLiars => _numberOfLiars;
  String get mode => _mode;

  void setNumberOfPlayers(int count) {
    _numberOfPlayers = count;
    notifyListeners();
  }

  void setNumberOfLiars(int count) {
    _numberOfLiars = count;
    notifyListeners();
  }

  void setMode(String newMode) {
    _mode = newMode;
    notifyListeners();
  }
}
