import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;

  bool get isAuthenticated => _token != null;
  final baseUrl = 'http://localhost:3000';
  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _token = data['access_token'] ?? data['token'];
      _email = email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('email', _email!);

      notifyListeners();
      return true;
    } else {
      _token = null;
      _email = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateProfile(String email, String password) async {
    if (_token == null) return false;

    final url = Uri.parse('$baseUrl/users/update');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      _email = email;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    notifyListeners();
  }
}
