import 'package:equatable/equatable.dart';
import 'package:project_repository/src/models/models.dart';

class Team extends Equatable {
  const Team({
    required this.name,
    required this.members,
  });

  final String name;
  final List<TeamMember> members;

  @override
  List<Object?> get props => [name, members];

  static const empty = Team(name: '', members: []);
}
