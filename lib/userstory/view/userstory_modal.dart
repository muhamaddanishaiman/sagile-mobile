import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_repository/project_repository.dart';
import 'package:sagile_mobile/project/bloc/project_bloc.dart';

class UserstoryModal extends StatefulWidget {
  const UserstoryModal({
    super.key,
    required this.userstoryId,
  });

  final int userstoryId;

  @override
  State<UserstoryModal> createState() => _UserstoryModalState();
}

class _UserstoryModalState extends State<UserstoryModal> {
  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final _project = state.projects.firstWhere(
            (project) =>
                project.userstories.firstWhere(
                    (userstory) => userstory.id == widget.userstoryId,
                    orElse: () => Userstory.empty) !=
                Userstory.empty,
            orElse: () => Project.empty);
        final _userstory = _project.userstories.firstWhere(
            (userstory) => userstory.id == widget.userstoryId,
            orElse: () => Userstory.empty);

        return AlertDialog(
          titlePadding: EdgeInsets.all(16.0),
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.zero,
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    '${_userstory.status.title}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary
                        // fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              Text(
                '${_userstory.title}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._userstory.tasks.map(
                  (task) => Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                color: Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    '${task.status.title}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${task.title}',
                                style: TextStyle(
                                  fontSize: 12,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                color: Colors.green,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    '${DateFormat('dd/MM/yyyy').format(task.startDate!)}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                margin: EdgeInsets.zero,
                                color: Colors.red,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    '${DateFormat('dd/MM/yyyy').format(task.endDate!)}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Text('Status: ${userstory.status.title}'),
                // Text('Team: ${userstory.}'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _navigator.pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
