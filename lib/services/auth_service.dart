import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'userId';

  // Store user token
  static Future<bool> storeUserToken(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    return true;
  }

  // Get user token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // Logout user
  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    return true;
  }

  // Register user
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Registration successful',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Store token and user ID
        await storeUserToken(responseData['token'], responseData['userId']);
        
        return {
          'success': true,
          'message': 'Login successful',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get logged in user details
  static Future<Map<String, dynamic>> getLoggedInUser() async {
    try {
      final token = await getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      final response = await http.post(
        Uri.parse(ApiConfig.getUser),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User details retrieved successfully',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getUserToken();
      print('Retrieved token for getCurrentUser: $token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      print('Fetching current user data...');
      final response = await http.post(
        Uri.parse('${ApiConfig.rootUrl}/api/users/getUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      ).timeout(ApiConfig.timeout);

      print('Get user response status: ${response.statusCode}');
      print('Get user response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          final user = User.fromJson(responseData);
          
          return {
            'success': true,
            'message': 'User data retrieved successfully',
            'data': user,
          };
        } catch (e) {
          print('Error parsing user data: $e');
          return {
            'success': false,
            'message': 'Error parsing user data: ${e.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        // Clear token if unauthorized
        await logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to get user data',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to get user data',
          };
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update user
  static Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      final token = await getUserToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }
      
      print('Updating user data: $userData');
      final response = await http.put(
        Uri.parse('${ApiConfig.rootUrl}/api/users/getUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          ...userData,
        }),
      ).timeout(ApiConfig.timeout);

      print('Update user response status: ${response.statusCode}');
      print('Update user response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          final user = User.fromJson(responseData);
          
          return {
            'success': true,
            'message': 'Profile updated successfully',
            'data': user,
          };
        } catch (e) {
          print('Error parsing updated user data: $e');
          return {
            'success': false,
            'message': 'Error parsing updated user data',
          };
        }
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message = responseData['message'] ?? 'Failed to update profile';
        } catch (e) {
          message = 'Failed to update profile';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('Error updating user: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
