import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_storage.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await UserStorage.getUser();
      _isLoggedIn = _currentUser?.isLoggedIn ?? false;
    } catch (e) {
      print('Error loading user from storage: $e');
      _currentUser = null;
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(UserModel user) async {
    _currentUser = user;
    _isLoggedIn = user.isLoggedIn;
    await UserStorage.saveUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await UserStorage.clearUser();
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    await UserStorage.saveUser(user);
    notifyListeners();
  }

  String? get userName => _currentUser?.name;
  String? get userEmail => _currentUser?.email;
  String? get userRole => _currentUser?.role;
  String? get authToken => _currentUser?.token;
}
