import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _username;
  String? _email;
  bool _isLoggedIn = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;
  String? get token => _token;

  // Mock login - Replace with actual API call
  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (email.isNotEmpty && password.length >= 6) {
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        _email = email;
        _username = email.split('@')[0];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Mock register - Replace with actual API call
  Future<bool> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password == confirmPassword &&
          password.length >= 6) {
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        _email = email;
        _username = username;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile(String username, String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _username = username;
      _email = email;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  void logout() {
    _token = null;
    _username = null;
    _email = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
