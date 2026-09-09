import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String _userName = 'Varshini';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _userName;
  String get userPhone => '+91 98765 43210';
  String get userEmail => 'parent@pawcare.app';

  AuthProvider() {
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    _userName = await _authService.getUserName();
    notifyListeners();
  }

  Future<bool> checkSession() async {
    final active = await _authService.hasActiveSession();
    if (active) {
      await _loadUserName();
    }
    return active;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _authService.signUp(email: email, password: password, name: name);
    _isLoading = false;

    if (error == null) {
      _userName = name;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _authService.login(email: email, password: password);
    _isLoading = false;

    if (error == null) {
      await _loadUserName();
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
