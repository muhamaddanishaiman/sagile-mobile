import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:network_repository/network_repository.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

/********************************************************* 
Repository to handle authentication-related requests
2026-01-03 (Taufiq): Added try catch blocks and debug prints
***********************************************************/

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  String token = '';

  // dunno
  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    try {
      final res = await requestAuth(password: password, username: username);
      print("Status: ${res.statusCode}");
      print("Headers: ${res.headers}");
      print("Body: ${res.body}");

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final success = json['success'] as bool;

      if (success) {
        final data = json['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        this.token = token;
        _controller.add(AuthenticationStatus.authenticated);
      } else {
        _controller.add(AuthenticationStatus.unauthenticated);
      }
    } catch (e, stacktrace) {
      print("Exception: $e");
      print("Stacktrace: $stacktrace");
    }
  }

  void logOut() {
    token = '';
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();

  Future<http.Response> requestAuth({
    required String username,
    required String password,
  }) {
    print("requesting stuff hihi");
    return http.post(
      Uri.parse(NetworkRepository.loginURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': '69420',
      },
      body: jsonEncode(<String, String>{
        'email': username,
        'password': password,
      }),
    );
  }

  Future<http.Response> requestAuthLogOut() {
    return http.get(Uri.parse(NetworkRepository.logoutURL));
  }
}
