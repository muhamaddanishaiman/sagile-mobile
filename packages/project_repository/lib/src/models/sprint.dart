import 'package:equatable/equatable.dart';

class Sprint extends Equatable {
  const Sprint({
    required this.sprintId,
    required this.sprintName,
    required this.startSprint,
    required this.endSprint,
    required this.activeSprint,
  });

  final int sprintId;
  final String sprintName;
  final DateTime startSprint;
  final DateTime endSprint;
  final int? activeSprint;

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      sprintId: int.tryParse(json['sprint_id']?.toString() ?? '0') ?? 0,
      sprintName: json['sprint_name']?.toString() ?? '',
      startSprint: DateTime.tryParse(json['start_sprint']?.toString() ?? '') ?? DateTime.now(),
      endSprint: DateTime.tryParse(json['end_sprint']?.toString() ?? '') ?? DateTime.now(),
      activeSprint: int.tryParse(json['active_sprint']?.toString() ?? ''),
    );
  }

  @override
  List<Object?> get props => [sprintId, sprintName, startSprint, endSprint, activeSprint];

  static final empty = Sprint(
      sprintId: 0, 
      sprintName: '', 
      startSprint: DateTime.now(), 
      endSprint: DateTime.now(), 
      activeSprint: null
  );
}
