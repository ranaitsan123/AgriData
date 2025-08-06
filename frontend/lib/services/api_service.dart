import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl =
      'https://deciding-highly-hermit.ngrok-free.app';
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  String? _token;
  String? get token => _token;

  /// Load token from local storage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: _defaultHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      return true;
    } else {
      print('❌ Login failed: ${response.body}');
      return false;
    }
  }

  /// Register a new user
  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: _defaultHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('❌ Registration failed: ${response.body}');
      return false;
    }
  }

  /// Logout user and blacklist token
  Future<void> logout() async {
    if (_token == null) return;

    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {..._defaultHeaders, 'Authorization': 'Bearer $_token'},
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;

    if (response.statusCode == 200) {
      print('✅ Logged out');
    } else {
      print('⚠️ Logout failed: ${response.body}');
    }
  }

  /// Fetch current user's profile
  Future<Map<String, dynamic>?> getProfile() async {
    if (_token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {..._defaultHeaders, 'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Profile fetch error: ${response.body}');
      return null;
    }
  }

  /// Get real-time sensor readings
  Future<Map<String, dynamic>?> getSensorData() async {
    if (_token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/data'),
      headers: {..._defaultHeaders, 'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Sensor data fetch error: ${response.body}');
      return null;
    }
  }

  /// Get top 10 unhandled alerts
  Future<List<dynamic>> getLatestAlerts() async {
    if (_token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/alerts/active'),
      headers: {..._defaultHeaders, 'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Latest alerts fetch error: ${response.body}');
      return [];
    }
  }

  /// Get full alert history
  Future<List<dynamic>> getAlertHistory() async {
    if (_token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/alerts/history'),
      headers: {..._defaultHeaders, 'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Alert history fetch error: ${response.body}');
      return [];
    }
  }

  /// Handle alert (send control command via MQTT)
  Future<bool> handleAlert({
    required String alertId,
    required String action,
    required String device,
  }) async {
    if (_token == null) {
      print('❌ Cannot handle alert: no token');
      return false;
    }

    final url = Uri.parse('$_baseUrl/alerts/$alertId');

    final response = await http.put(
      url,
      headers: {..._defaultHeaders, 'Authorization': 'Bearer $_token'},
      body: jsonEncode({'action': action, 'device': device}),
    );

    if (response.statusCode == 200) {
      print('✅ Alert handled successfully: ${response.body}');
      return true;
    } else {
      print(
        '❌ Failed to handle alert: ${response.statusCode} | ${response.body}',
      );
      return false;
    }
  }

  /// Optional: Request password reset
  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: _defaultHeaders,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('✅ Password reset request sent');
        return true;
      } else {
        print('❌ Password reset failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error during password reset: $e');
      return false;
    }
  }
}
