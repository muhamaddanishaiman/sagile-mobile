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
        print("User Response: ${res.body}");
        final json = jsonDecode(res.body);
        Map<String, dynamic> user;

        if (json is Map<String, dynamic> && json.containsKey('data')) {
           final data = json['data'];
           if (data is Map<String, dynamic> && data.containsKey('user')) {
             user = data['user'];
           } else if (data is Map<String, dynamic>) {
             user = data;
           } else {
             user = {};
           }
        } else if (json is Map<String, dynamic>) {
           user = json; // Direct user object
        } else {
           user = {};
        }

        final id = user['id']?.toString() ?? '';
        final name = user['name']?.toString() ?? '';
        final username = user['username']?.toString() ?? '';
        final email = user['email']?.toString() ?? '';

        if (id.isNotEmpty) {
          _user = User(id, name: name, username: username, email: email);
        }
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
