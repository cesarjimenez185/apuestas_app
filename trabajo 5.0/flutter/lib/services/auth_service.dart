import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  
  AuthService(this._apiService);
  
  bool get isAuthenticated => _apiService.token != null;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    return _apiService.login(email, password);
  }
  
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return _apiService.register(name, email, password);
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    return _apiService.getProfile();
  }
  
  Future<void> logout() async {
    await _apiService.clearToken();
  }
}
