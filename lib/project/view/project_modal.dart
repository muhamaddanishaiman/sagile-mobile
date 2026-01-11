import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_repository/project_repository.dart';
import 'package:sagile_mobile/project/bloc/project_bloc.dart';
import 'package:sagile_mobile/burndown/burndown.dart';

class ProjectModal extends StatefulWidget {
  const ProjectModal({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  State<ProjectModal> createState() => _ProjectModalState();
}

class _ProjectModalState extends State<ProjectModal> {
  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final project = state.projects
            .firstWhere((element) => element.id == widget.projectId);
        return AlertDialog(
          title: Text('${project.title}'),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${project.description}'),
                Text('Team: ${project.team}'),
                const SizedBox(height: 8),
                Text('Start Date: ${project.startDate != null ? DateFormat('dd/MM/yyyy').format(project.startDate!) : "-"}'),
                Text('End Date: ${project.endDate != null ? DateFormat('dd/MM/yyyy').format(project.endDate!) : "-"}'),
              ],
            ),
          ),
          actions: [
            // Edit button removed for view-only mode
            ElevatedButton(
              onPressed: () {
                _navigator.push(
                  MaterialPageRoute(
                    builder: (context) => BurndownPage(projectId: project.id),
                  ),
                );
              },
              child: Text("View Burndown Chart"),
            ),
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

// View Only Mode - Edit classes commented out
/*
class ProjectModalEdit extends StatefulWidget {
  const ProjectModalEdit({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  State<ProjectModalEdit> createState() => _ProjectModalEditState();
}

class _ProjectModalEditState extends State<ProjectModalEdit> {
  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);
    final _formKey = GlobalKey<FormState>();

    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final _project = state.projects
            .firstWhere((element) => element.id == widget.projectId);
        final statuses = _project.statuses;
        final userstories = _project.userstories;
        final _controller = <String, TextEditingController>{
          'title': TextEditingController.fromValue(
              TextEditingValue(text: _project.title)),
          'description': TextEditingController.fromValue(
              TextEditingValue(text: _project.description)),
          'team': TextEditingController.fromValue(
              TextEditingValue(text: _project.team)),
          'startDate': TextEditingController.fromValue(TextEditingValue(
              text: DateFormat('dd/MM/yyyy').format(_project.startDate!))),
          'endDate': TextEditingController.fromValue(TextEditingValue(
              text: DateFormat('dd/MM/yyyy').format(_project.endDate!))),
        };

        return Scaffold(
          appBar: AppBar(title: Text('Edit Project'), actions: [
            IconButton(
              onPressed: () {
                final isValid = _formKey.currentState!.validate();
                if (isValid) {
                  final _project = Project(
                    widget.projectId,
                    title: _controller['title']!.text,
                    description: _controller['description']!.text,
                    startDate: DateFormat('dd/MM/yyyy')
                        .parse(_controller['startDate']!.text),
                    endDate: DateFormat('dd/MM/yyyy')
                        .parse(_controller['endDate']!.text),
                    team: _controller['team']!.text,
                    statuses: statuses,
                    userstories: userstories,
                  );
                  _project.reorderStatuses();

                  context.read<ProjectBloc>()
                    ..add(ProjectStatusChanged(ProjectStatus.loading))
                    ..add(ProjectStatusChanged(ProjectStatus.updatingProject,
                        project: _project));
                  _navigator.pop();
                }
              },
              icon: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )
          ]),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _controller['title'],
                            decoration: InputDecoration(
                              labelText: "Title",
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _controller['description'],
                            decoration: InputDecoration(
                              labelText: "Description",
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            // maxLength: 300,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _controller['team'],
                            decoration: InputDecoration(
                              labelText: "Team",
                              isDense: true,
                              border: OutlineInputBorder(),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controller['startDate'],
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Start Date",
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabled: false,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: _project.startDate!,
                                  firstDate:
                                      DateTime(DateTime.now().year - 1, 1, 1),
                                  lastDate: DateTime(DateTime.now().year + 25),
                                );
                                _controller['startDate']!.text =
                                    DateFormat('dd/MM/yyyy').format(newDate!);
                                if (newDate.compareTo(DateFormat('dd/MM/yyyy')
                                        .parse(_controller['endDate']!.text)) >
                                    0) {
                                  _controller['endDate']!.text =
                                      DateFormat('dd/MM/yyyy').format(newDate);
                                }
                              },
                              icon: Icon(Icons.calendar_month))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controller['endDate'],
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "End Date",
                                isDense: true,
                                border: OutlineInputBorder(),
                                enabled: false,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: _project.endDate!,
                                  firstDate: DateFormat('dd/MM/yyyy')
                                      .parse(_controller['startDate']!.text),
                                  lastDate: DateTime(DateTime.now().year + 25),
                                );
                                _controller['endDate']!.text =
                                    DateFormat('dd/MM/yyyy').format(newDate!);
                              },
                              icon: Icon(Icons.calendar_month))
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigator.push(
                          MaterialPageRoute(
                            builder: (context) => ProjectModalStatus(
                              projectId: widget.projectId,
                            ),
                          ),
                        );
                      },
                      child: Text("Manage Statuses"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProjectModalStatus extends StatefulWidget {
  const ProjectModalStatus({
    super.key,
    required this.projectId,
  });
  final int projectId;

  @override
  State<ProjectModalStatus> createState() => _ProjectModalStatusState();
}

class _ProjectModalStatusState extends State<ProjectModalStatus> {
  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final _project = state.projects
            .firstWhere((project) => project.id == widget.projectId);

        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Statuses'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ProjectModalStatusNew(
                            projectId: _project.id,
                          ),
                        );
                      },
                      child: Text('Add New Status')),
                  Expanded(
                    child: ReorderableListView(
                      // shrinkWrap: true,
                      children: <Widget>[
                        ..._project.statuses.map(
                          (status) => Card(
                            key: ValueKey('${status.id}'),
                            child: ListTile(
                              title: Text('${status.title}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ProjectModalStatusEdit(
                                          projectId: _project.id,
                                          statusId: status.id,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ProjectModalStatusDelete(
                                          projectId: _project.id,
                                          statusId: status.id,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          _project.statuses.insert(
                              newIndex, _project.statuses.removeAt(oldIndex));
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProjectModalStatusNew extends StatefulWidget {
  const ProjectModalStatusNew({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  State<ProjectModalStatusNew> createState() => _ProjectModalStatusNewState();
}

class _ProjectModalStatusNewState extends State<ProjectModalStatusNew> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final _project = state.projects
            .firstWhere((project) => project.id == widget.projectId);
        final _controller = <String, TextEditingController>{
          'title': TextEditingController(),
        };

        return AlertDialog(
          title: Text('New Status'),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _controller['title'],
                    decoration: InputDecoration(
                      labelText: "Title",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final isValid = _formKey.currentState!.validate();
                if (isValid) {
                  final updatedStatus =
                      Status(-1, title: _controller['title']!.text);
                  _project.updateStatus(updatedStatus);
                  _project.reorderStatuses();
                  context.read<ProjectBloc>()
                    ..add(ProjectStatusChanged(ProjectStatus.loading))
                    ..add(ProjectStatusChanged(ProjectStatus.ready));

                  _navigator.pop();
                }
              },
              child: Text("Save"),
            ),
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

class ProjectModalStatusEdit extends StatefulWidget {
  const ProjectModalStatusEdit({
    super.key,
    required this.projectId,
    required this.statusId,
  });

  final int projectId;
  final int statusId;

  @override
  State<ProjectModalStatusEdit> createState() => _ProjectModalStatusEditState();
}

class _ProjectModalStatusEditState extends State<ProjectModalStatusEdit> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final _project = state.projects
            .firstWhere((project) => project.id == widget.projectId);
        final _status = _project.statuses
            .firstWhere((status) => status.id == widget.statusId);
        final _controller = <String, TextEditingController>{
          'title': TextEditingController.fromValue(
              TextEditingValue(text: _status.title)),
        };

        return AlertDialog(
          title: Text('Edit Status'),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _controller['title'],
                    decoration: InputDecoration(
                      labelText: "Title",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final isValid = _formKey.currentState!.validate();
                if (isValid) {
                  final updatedStatus = Status(widget.statusId,
                      title: _controller['title']!.text);
                  _project.updateStatus(updatedStatus);
                  _project.reorderStatuses();
                  context.read<ProjectBloc>()
                    ..add(ProjectStatusChanged(ProjectStatus.loading))
                    ..add(ProjectStatusChanged(ProjectStatus.ready));

                  _navigator.pop();
                }
              },
              child: Text("Save"),
            ),
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

class ProjectModalStatusDelete extends StatefulWidget {
  const ProjectModalStatusDelete({
    super.key,
    required this.projectId,
    required this.statusId,
  });

  final int projectId;
  final int statusId;

  @override
  State<ProjectModalStatusDelete> createState() =>
      _ProjectModalStatusDeleteState();
}

class _ProjectModalStatusDeleteState extends State<ProjectModalStatusDelete> {
  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        final _project = state.projects.firstWhere(
            (project) => project.id == widget.projectId,
            orElse: () => Project.empty);
        final _status = _project.statuses.firstWhere(
            (status) => status.id == widget.statusId,
            orElse: () => Status.empty);
        return AlertDialog(
          title: Text('${_status.title}'),
          content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text('Are you sure you want to delete this status?')),
          actions: [
            ElevatedButton(
              onPressed: () {
                _navigator.pop();
                _project.removeStatus(_status.id);
                _project.reorderStatuses();
                context.read<ProjectBloc>()
                  ..add(ProjectStatusChanged(ProjectStatus.loading))
                  ..add(ProjectStatusChanged(ProjectStatus.ready));
              },
              child: Text("Delete"),
            ),
            ElevatedButton(
              onPressed: () {
                _navigator.pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
*/
