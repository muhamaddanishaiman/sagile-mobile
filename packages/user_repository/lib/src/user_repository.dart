import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:network_repository/network_repository.dart';
import 'package:user_repository/src/models/models.dart';

/********************************************************* 
Repository to handle user-related requests
2026-01-03 (Taufiq): Added Some debug prints to trace issues
***********************************************************/

class UserRepository {
  User? _user = User.empty;

  Future<User?> getUser(String token) async {
    if (_user == User.empty) {
      print("Requesting user");
      try {
        final res = await requestUser(token: token);
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;

        final id = user['id'].toString();
        final name = user['name'].toString();
        final username = user['username'].toString();
        final email = user['email'].toString();

        _user = User(id, name: name, username: username, email: email);
      } catch (error) {
        print("Error retrieving user: ${error.toString()}");
      }
    }
    print("User retrieved: $_user");
    return _user;
  }

  Future<http.Response> requestUser({
    required String token,
  }) {
    return http.get(
      Uri.parse(NetworkRepository.userURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': '69420',
        'Authorization': 'Bearer $token'
      },
    );
  }

  void logOut() {
    _user = User.empty;
  }
}
