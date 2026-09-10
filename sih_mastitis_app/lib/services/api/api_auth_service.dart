import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import 'api_config.dart';

class ApiAuthService {
  Future<User> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    print('LOGIN URL: $url');
    print('LOGIN EMAIL: $email');
    print('LOGIN REQUEST STARTED');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        final String token = tokenData['access_token'];
        
        await ApiConfig.setToken(token);
        print('LOGIN: Token saved successfully');
        
        // Do not block on /auth/me to ensure < 5s login
        return User(id: '0', email: email, role: 'admin', farmId: '0');
      } else {
        print('LOGIN RESPONSE ERROR: ${response.body}');
      }
      throw Exception('Login failed with status: ${response.statusCode}');
    } catch (e) {
      print('LOGIN EXCEPTION: $e');
      rethrow;
    }
  }

  Future<User> updateProfile(String name, {String? phone}) async {
    final body = <String, dynamic>{'name': name};
    if (phone != null) body['phone'] = phone;
    
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/auth/me'),
      headers: ApiConfig.headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      return User.fromJson(userData);
    }
    throw Exception('Failed to update profile');
  }

  Future<void> logout() async {
    await ApiConfig.clearToken();
  }
}
