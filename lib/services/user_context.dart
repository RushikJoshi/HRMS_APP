import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/user_role.dart';

class UserContext extends ChangeNotifier {
  static final UserContext _instance = UserContext._internal();
  
  factory UserContext() {
    return _instance;
  }
  
  UserContext._internal();

  Employee? _currentUser;

  Employee? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void login(Employee user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Debug/Dev Helper
  void setCurrentUser(Employee? user) {
    if (_currentUser?.id != user?.id) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
