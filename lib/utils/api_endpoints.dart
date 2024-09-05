class ApiEndPoints {
  static final String baseUrl = 'http://192.168.56.1:8082/';
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
  static _WorkspaceEndPoints workspaceEndPoints = _WorkspaceEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = 'auth/register';
  final String loginEmail = 'auth/login';
}
class _WorkspaceEndPoints {
  final String getWorkspace = 'manage/workspaces';

}