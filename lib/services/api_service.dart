import 'dart:convert';
import 'package:flutter_login/services/storage_service.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://taskmanager-refresh-token-tejas.onrender.com';
  
  // Registration API endpoint
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required int age,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'age': age,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Registration failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login API endpoint
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Login failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Parse login response
  static LoginResponse? parseLoginResponse(Map<String, dynamic> responseData) {
    try {
      return LoginResponse.fromJson(responseData);
    } catch (e) {
      return null;
    }
  }

  // Forgot API endpoint
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Login failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout API endpoint
  static Future<Map<String, dynamic>> logout({
    required String email,
    required String token,
  }) async {
    try {
      print('Bearer $token');
      final response = await http.post(
        Uri.parse('$baseUrl/users/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
        }),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Logout failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // List all tasks endpoint
  static Future<Map<String, dynamic>> getTasks({
    bool? completed,
    int limit = 10,
    int skip = 0,
    String sortBy = 'createdAt:desc',
  }) async {
    try {
      // Construct query parameters
      String queryString = 'limit=$limit&skip=$skip&sort=$sortBy';
      if (completed != null) {
        queryString += '&completed=$completed';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tasks?$queryString'),
        headers: {
          'Authorization': 'Bearer ${await StorageService.getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Failed to fetch tasks'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createTask({required String description}) async {
    try {
      final token = await StorageService.getAuthToken(); // Or wherever you store it

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'description': description,
          'completed': false, // Optional: backend defaults this anyway
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['error']?.toString() ?? 'Failed to create task'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
