import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Team>? _teams;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      final token = context.read<AuthenticationRepository>().token;
      final repo = context.read<ProjectRepository>();
      final teams = await repo.getTeams(token: token);
      if (mounted) {
        setState(() {
          _teams = teams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          TextButton(onPressed: _refresh, child: const Text("Retry"))
        ],
      ));
    }

    if (_teams == null || _teams!.isEmpty) {
      return const Center(child: Text("No teams found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _teams!.length,
      itemBuilder: (context, index) {
        final team = _teams![index];
        return TeamCard(team: team);
      },
    );
  }
}

class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(team.name),
        subtitle: Text('${team.members.length} members'),
        children: [
          ...team.members.map((member) => ListTile(
                leading: CircleAvatar(
                  child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?'),
                ),
                title: Text(member.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.role),
                    if (member.email.isNotEmpty)
                      Text(member.email, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
