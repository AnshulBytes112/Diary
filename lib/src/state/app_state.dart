import 'package:flutter/foundation.dart';

import '../models/diary_entry.dart';

class AppState extends ChangeNotifier {
  Mood _selectedMood = Mood.happy;
  bool _isPublic = true;

  Mood get selectedMood => _selectedMood;
  bool get isPublic => _isPublic;

  void setMood(Mood mood) {
    if (_selectedMood == mood) return;
    _selectedMood = mood;
    notifyListeners();
  }

  void setPublic(bool value) {
    if (_isPublic == value) return;
    _isPublic = value;
    notifyListeners();
  }
}

