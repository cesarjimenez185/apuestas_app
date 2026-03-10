import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  String? _token;
  
  ApiService() {
    _loadToken();
  }
  
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }
  
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  String? get token => _token;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Error en la solicitud');
    }
  }
  
  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    await setToken(data['token']);
    return data;
  }
  
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final data = await post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    await setToken(data['token']);
    return data;
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    return get('/auth/profile');
  }
  
  // Matches
  Future<List<dynamic>> getMatches({String? league, String? status}) async {
    String endpoint = '/matches';
    final params = <String>[];
    if (league != null && league != 'all') params.add('league=$league');
    if (status != null && status != 'all') params.add('status=$status');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';
    return get(endpoint);
  }
  
  Future<List<dynamic>> getLiveMatches() async {
    return get('/matches/live');
  }
  
  Future<void> seedMatches() async {
    await post('/matches/seed');
  }
  
  // Bets
  Future<Map<String, dynamic>> placeBet({
    required String matchId,
    required String betType,
    required String selection,
    required double odds,
    required double amount,
  }) async {
    return post('/bets', body: {
      'matchId': matchId,
      'betType': betType,
      'selection': selection,
      'odds': odds,
      'amount': amount,
    });
  }
  
  Future<List<dynamic>> getUserBets({String? status}) async {
    String endpoint = '/bets';
    if (status != null && status != 'all') endpoint += '?status=$status';
    return get(endpoint);
  }
}
