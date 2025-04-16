import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _username;
  String? _email;
  String? _token;
  bool _isLoading = false;
  String? _error;

  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;

  UserProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getUserToken();
      final userId = await AuthService.getUserId();
      
      if (token != null && userId != null) {
        _token = token;
        _userId = userId;
        
        // Get user details
        final result = await AuthService.getLoggedInUser();
        if (result['success']) {
          final userData = result['data'];
          _username = userData['username'];
          _email = userData['email'];
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await AuthService.login(username, password);
      
      if (result['success']) {
        final userData = result['data'];
        _token = userData['token'];
        _userId = userData['userId'];
        _username = userData['username'];
        _email = userData['email'];
        _error = null;
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(username, email, password);
      
      if (result['success']) {
        // After successful registration, login the user
        return await login(username, password);
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.logout();
      
      if (result) {
        _token = null;
        _userId = null;
        _username = null;
        _email = null;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
