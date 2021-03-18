import 'package:flutter/foundation.dart';

class MenuProvider with ChangeNotifier {
  bool _isOpen = false;
  int _index;
  List<String> _logos;

  int get index => _index;
  bool get isOpen => _isOpen;
  List<String> get logos => _logos;

  void toogle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

  void setLogos(List<String> logos) {
    _logos = logos;
    notifyListeners();
  }
}
