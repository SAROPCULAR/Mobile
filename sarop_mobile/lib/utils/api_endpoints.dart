class ApiEndPoints {
  static final String baseUrl = 'http://192.168.56.1:8082/auth';
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '/register';
  final String loginEmail = '/login';
}