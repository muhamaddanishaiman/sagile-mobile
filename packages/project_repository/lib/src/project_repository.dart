import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:network_repository/network_repository.dart';
import 'package:project_repository/src/models/models.dart';

/********************************************************* 
Repository to handle project-related requests
2026-01-03 (Taufiq): Added Some debug prints to trace issues, temp resolve to empty list [] for tasks and projects - debugging purpose
***********************************************************/

enum ProjectStatus {
  error,
  uninitialized,
  loading,
  ready,
  retrieving,
  updatingProject,
  updatingUserstory,
  removingUserstory
}

class ProjectRepository {
  final _controller = StreamController<ProjectStatus>();

  Stream<ProjectStatus> get status async* {
    yield* _controller.stream;
  }

  // Requests to retrieve Projects
  Future<List<Project>?> getProject(String token) async {
    try {
      final res = await requestGetProject(token: token);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      print("Parsed JSON: $json");
      final success = json['success'] as bool;
      if (success) {
        final projects = <Project>[];
        final data = json['data'] as List;

        for (final projectJsonString in data) {
          try {
            final projectJsonObject = projectJsonString as Map<String, dynamic>;

            final statuses = <Status>[];
            final statusesList = projectJsonObject['statuses'] as List? ?? [];
            if (statusesList.isNotEmpty) {
              for (final statusJsonString in statusesList) {
                final statusJsonObject = statusJsonString as Map<String, dynamic>;
                final status = Status(
                  int.tryParse(statusJsonObject['id']?.toString() ?? '0') ?? 0,
                  order: int.tryParse(statusJsonObject['order']?.toString() ?? '0') ?? 0,
                  title: statusJsonObject['title']?.toString() ?? '',
                );
                statuses.add(status);
              }
            }

            final userstories = <Userstory>[];
            final userstoriesList =
                projectJsonObject['userstories'] as List? ?? [];
            if (userstoriesList.isNotEmpty) {
              for (final userstoryJsonString in userstoriesList) {
                final userstoryJsonObject =
                    userstoryJsonString as Map<String, dynamic>;

                final tasks = <Task>[];
                final tasksList = userstoryJsonObject['tasks'] as List? ?? [];
                if (tasksList.isNotEmpty) {
                  for (final taskJsonString in tasksList) {
                    final taskJsonObject = taskJsonString as Map<String, dynamic>;
                    
                    final statusId = int.tryParse(taskJsonObject['status_id']?.toString() ?? '0') ?? 0;
                    
                    final task = Task(
                      int.tryParse(taskJsonObject['id']?.toString() ?? '0') ?? 0,
                      order: int.tryParse(taskJsonObject['order']?.toString() ?? '0') ?? 0,
                      title: taskJsonObject['title']?.toString() ?? 'Untitled Task',
                      status: statuses.firstWhere(
                        (status) => status.id == statusId,
                        orElse: () => Status.empty,
                      ),
                      startDate: DateTime.tryParse(
                        taskJsonObject['start_date']?.toString() ?? '',
                      ),
                      endDate: DateTime.tryParse(
                        taskJsonObject['end_date']?.toString() ?? '',
                      ),
                    );

                    tasks.add(task);
                  }
                }

                final statusId = int.tryParse(userstoryJsonObject['status_id']?.toString() ?? '0') ?? 0;

                final userstory = Userstory(
                  int.tryParse(userstoryJsonObject['u_id']?.toString() ?? '') ?? 
                  int.tryParse(userstoryJsonObject['id']?.toString() ?? '0') ?? 0,
                  title: userstoryJsonObject['title']?.toString() ?? 
                         userstoryJsonObject['user_story']?.toString() ?? 'Untitled Story',
                  status: statuses.firstWhere(
                    (status) => status.id == statusId,
                    orElse: () => Status.empty,
                  ),
                  tasks: tasks,
                );
                userstories.add(userstory);
              }
            }

            final project = Project(
              int.tryParse(projectJsonObject['id']?.toString() ?? '0') ?? 0,
              title: projectJsonObject['title']?.toString() ??
                  projectJsonObject['name']?.toString() ??
                  'Untitled',
              description: projectJsonObject['description']?.toString() ?? '',
              startDate: DateTime.tryParse(projectJsonObject['start_date']?.toString() ?? ''),
              endDate: DateTime.tryParse(projectJsonObject['end_date']?.toString() ?? ''),
              team: projectJsonObject['team']?.toString() ?? '',
              statuses: statuses,
              userstories: userstories,
            );
            projects.add(project);
          } catch (e) {
            print("Error parsing project: $e");
          }
        }
        _controller.add(ProjectStatus.ready);
        return projects;
      }
    } catch (error) {}
    _controller.add(ProjectStatus.error);
    return null;
  }

  Future<http.Response> requestGetProject({
    required String token,
  }) {
    return http.get(
      Uri.parse(NetworkRepository.projectURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': '69420',
        'Authorization': 'Bearer $token'
      },
    );
  }

  // Request to update Project
  Future<Project?> updateProject(String token, Project project) async {
    final res = await requestUpdateProject(token: token, project: project);
    final json = jsonDecode(res.body) as Map<String, dynamic>;

    final success = json['success'] as bool;
    if (success) {
      final projectJsonObject = json['data'] as Map<String, dynamic>;

      final statuses = <Status>[];
      final statusesList = projectJsonObject['statuses'] as List? ?? [];
      if (statusesList.isNotEmpty) {
        for (final statusJsonString in statusesList) {
          final statusJsonObject = statusJsonString as Map<String, dynamic>;
          final status = Status(
            int.parse(
              statusJsonObject['id']!.toString(),
            ),
            order: int.parse(
              statusJsonObject['order']!.toString(),
            ),
            title: statusJsonObject['title']!.toString(),
          );
          statuses.add(status);
        }
      }

      final updatedProject = Project(
        int.parse(projectJsonObject['id']!.toString()),
        title: projectJsonObject['title']!.toString(),
        description: projectJsonObject['description']!.toString(),
        startDate: DateTime.parse(projectJsonObject['start_date']!.toString()),
        endDate: DateTime.parse(projectJsonObject['end_date']!.toString()),
        team: projectJsonObject['team']!.toString(),
        statuses: statuses,
        userstories: project.userstories,
      );
      _controller.add(ProjectStatus.ready);
      return updatedProject;
    }

    _controller.add(ProjectStatus.error);
    return null;
  }

  Future<http.Response> requestUpdateProject({
    required String token,
    required Project project,
  }) {
    final url = '${NetworkRepository.projectURL}/${project.id}';
    final body = jsonEncode(
      <String, String>{
        'mode': 'project',
        'title': project.title,
        'description': project.description,
        'start_date': project.startDate!.toString(),
        'end_date': project.endDate!.toString(),
        'statuses': project.statuses
            .map(
              (status) => jsonEncode(
                status.id.toString() == '-1'
                    ? <String, String>{
                        'order': status.order.toString(),
                        'title': status.title,
                      }
                    : <String, String>{
                        'id': status.id.toString(),
                        'order': status.order.toString(),
                        'title': status.title,
                      },
              ),
            )
            .toList()
            .toString(),
        'userstories': project.userstories
            .map(
              (userstory) => jsonEncode(
                userstory.id.toString() == '-1'
                    ? <String, String>{
                        'title': userstory.title,
                        'status': userstory.status.id.toString(),
                      }
                    : <String, String>{
                        'id': userstory.id.toString(),
                        'title': userstory.title,
                        'status': userstory.status.id.toString(),
                      },
              ),
            )
            .toList()
            .toString(),
      },
    );

    return http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': '69420',
        'Authorization': 'Bearer $token'
      },
      body: body,
    );
  }

  Future<Userstory?> updateUserstory(String token, Userstory userstory) async {
    try {
      final res =
          await requestUpdateUserstory(token: token, userstory: userstory);
      final json = jsonDecode(res.body) as Map<String, dynamic>;

      final success = json['success'] as bool;
      if (success) {
        final userstoryJsonObject = json['data'] as Map<String, dynamic>;

        final statusObj = userstoryJsonObject['status'] as Map<String, dynamic>;
        final status = Status(
          statusObj['id'] as int,
          order: statusObj['order'] as int,
          title: statusObj['title'] as String,
        );

        final tasks = <Task>[];
        final tasksList = userstoryJsonObject['tasks'] as List? ?? [];
        if (tasksList.isNotEmpty) {
          for (final taskJsonString in tasksList) {
            final taskJsonObject = taskJsonString as Map<String, dynamic>;
            final task = Task(
              int.parse(
                taskJsonObject['id']!.toString(),
              ),
              order: int.parse(
                taskJsonObject['order']!.toString(),
              ),
              title: taskJsonObject['title']!.toString(),
              startDate:
                  DateTime.parse(taskJsonObject['start_date']!.toString()),
              endDate: DateTime.parse(taskJsonObject['end_date']!.toString()),
            );
            tasks.add(task);
          }
        }

        final updatedUserstory = Userstory(
          int.parse(userstoryJsonObject['id']!.toString()),
          title: userstoryJsonObject['title']!.toString(),
          status: status,
          tasks: tasks,
        );

        _controller.add(ProjectStatus.ready);
        return updatedUserstory;
      }
    } catch (e) {}

    _controller.add(ProjectStatus.error);
    return null;
  }

  Future<http.Response> requestUpdateUserstory({
    required String token,
    required Userstory userstory,
  }) {
    final url = '${NetworkRepository.projectURL}/${userstory.id}';
    final body = jsonEncode(
      <String, String>{
        'mode': 'userstory',
        'title': userstory.title,
        'status': userstory.status.id.toString(),
        'tasks': userstory.tasks
            .map(
              (task) => jsonEncode(
                task.id.toString() == '-1'
                    ? <String, String>{
                        'order': task.order.toString(),
                        'status': task.status.id.toString(),
                        'title': task.title,
                        'startDate': task.startDate!.toIso8601String(),
                        'endDate': task.endDate!.toIso8601String(),
                      }
                    : <String, String>{
                        'id': task.id.toString(),
                        'order': task.order.toString(),
                        'status': task.status.id.toString(),
                        'title': task.title,
                        'startDate': task.startDate!.toIso8601String(),
                        'endDate': task.endDate!.toIso8601String(),
                      },
              ),
            )
            .toList()
            .toString(),
      },
    );

    return http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': '69420',
        'Authorization': 'Bearer $token'
      },
      body: body,
    );
  }

  Future<Userstory?> removeUserstory(String token, Userstory userstory) async {
    try {
      final res =
          await requestRemoveUserstory(token: token, userstory: userstory);
      final json = jsonDecode(res.body) as Map<String, dynamic>;

      final success = json['success'] as bool;
      if (success) {
        final userstoryJsonObject = json['data'] as Map<String, dynamic>;

        final statusObj = userstoryJsonObject['status'] as Map<String, dynamic>;
        final status = Status(
          statusObj['id'] as int,
          order: statusObj['order'] as int,
          title: statusObj['title'] as String,
        );

        final removedUserstory = Userstory(
          int.parse(userstoryJsonObject['id']!.toString()),
          title: userstoryJsonObject['title']!.toString(),
          status: status,
        );
        // _controller.add(ProjectStatus.ready);
        return removedUserstory;
      }
    } catch (e) {}
    _controller.add(ProjectStatus.error);
    return null;
  }

  Future<http.Response> requestRemoveUserstory({
    required String token,
    required Userstory userstory,
  }) {
    final url = '${NetworkRepository.projectURL}/${userstory.id}';
    final body = jsonEncode(
      <String, String>{
        'mode': 'userstory',
      },
    );

    return http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'ngrok-skip-browser-warning': '69420',
        'Authorization': 'Bearer $token'
      },
      body: body,
    );
  }

  void clearCache() {
    _controller.add(ProjectStatus.uninitialized);
  }
}
