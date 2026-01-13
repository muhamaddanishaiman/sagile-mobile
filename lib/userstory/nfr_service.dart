import 'dart:convert';
import 'package:http/http.dart' as http;
import '../userstory/nfr_model.dart';
import '../userstory/nfr_factory.dart';

import 'package:network_repository/network_repository.dart';

class NFRService {
  // Use NetworkRepository for centralized URL management
  final String baseUrl = NetworkRepository.apiURL; 

  Future<List<NFR>> fetchLinkedNFR(int userStoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-stories/$userStoryId/nfrs'),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print('NFR API Response: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> nfrList = data['nfrs'];

      return nfrList.map((json) => NFRFactory.createNFR(json)).toList();
    } else {
      throw Exception('Failed to load Linked NFRs');
    }
  }
}
