import 'nfr_model.dart';

class NFRFactory {
  static NFR createNFR(Map<String, dynamic> json) {
    final String type = json['type'].toString().toLowerCase();

    switch (type) {
      case 'performance':
        return PerformanceNFR(
          id: json['id'],
          title: json['title'],
          description: json['description'],
        );
      case 'security':
        return SecurityNFR(
          id: json['id'],
          title: json['title'],
          description: json['description'],
        );
      default:
        throw Exception('Unknown NFR type: $type');
    }
  }
}
