/// {@template network_repository}
/// The interface and models for network-related such as URLs
/// {@endtemplate}

/********************************************************* 
Repository to handle network-related constants
2026-01-03 (Taufiq): Updated project url
***********************************************************/
class NetworkRepository {
  /// {@macro network_repository}
  const NetworkRepository();

  /// the main url
  static const mainURL = 'https://2fea2c9e57ec.ngrok-free.app';

  /// the api url
  static const apiURL = '$mainURL/api';

  /// the login url
  static const loginURL = '$apiURL/login';

  /// the logout url
  static const logoutURL = '$apiURL/logout';

  /// the user url
  static const userURL = '$apiURL/user';

  /// the project url
  static const projectURL = '$apiURL/projects';

  /// the status url
  static const statusURL = '$apiURL/status';

  /// the userstory url
  static const userstoryURL = '$apiURL/userstory';

  /// the task url
  static const taskURL = '$apiURL/task';
}
