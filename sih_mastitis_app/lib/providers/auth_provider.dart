import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../services/api/api_auth_service.dart';
import '../services/api/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final ApiAuthService _authService = ApiAuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String email, String password) async {
    // _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("AUTH PROVIDER LOGIN CALLED");
      // TODO: PROTOTYPE-ONLY authentication. Remove before production.
      _currentUser = User(id: 'prototype_id', email: email.isEmpty ? 'admin@prototype.com' : email, role: 'admin', farmId: 'prototype_farm');
      await ApiConfig.setToken("dummy_prototype_token");
      // _currentUser = await _authService.login(email, password);
    } catch (e) {
      _error = 'Login failed';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, {String? phone}) async {
    _error = null;
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        farmId: _currentUser!.farmId,
        email: _currentUser!.email,
        name: name,
        phone: phone ?? _currentUser!.phone,
        role: _currentUser!.role,
      );
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
