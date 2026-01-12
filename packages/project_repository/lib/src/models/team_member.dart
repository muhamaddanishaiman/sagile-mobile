import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String role;

  @override
  List<Object?> get props => [id, name, email, role];

  static const empty = TeamMember(id: -1, name: '', email: '', role: '');
}
