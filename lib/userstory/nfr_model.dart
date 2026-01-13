abstract class NFR {
  final int id;
  final String title;
  final String description;
  final String type;

  NFR({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });

  factory NFR.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Use NFRFactory to create instances');
  }
}

class PerformanceNFR extends NFR {
  PerformanceNFR({
    required int id,
    required String title,
    required String description,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: 'Performance',
        );
}

class SecurityNFR extends NFR {
  SecurityNFR({
    required int id,
    required String title,
    required String description,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: 'Security',
        );
}
