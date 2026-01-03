import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:project_repository/project_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({
    required ProjectRepository projectRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _projectRepository = projectRepository,
        _authenticationRepository = authenticationRepository,
        super(const ProjectState.uninitialized()) {
    on<ProjectStatusChanged>(_onProjectStatusChanged);
    _projectStatusSubscription = _projectRepository.status.listen(
      (status) => add(ProjectStatusChanged(status)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  final ProjectRepository _projectRepository;
  late StreamSubscription<ProjectStatus> _projectStatusSubscription;

  @override
  Future<void> close() {
    _projectStatusSubscription.cancel();
    return super.close();
  }

  // Checks for project status change due to state change
  Future<void> _onProjectStatusChanged(
    ProjectStatusChanged event,
    Emitter<ProjectState> emit,
  ) async {
    List<Project>? projects = [];
    print(event.status);
    switch (event.status) {
      // when projects of the user is not initialized
      case ProjectStatus.uninitialized:
        return emit(ProjectState.uninitialized());

      // when projects of the user is loading
      case ProjectStatus.loading:
        return emit(ProjectState.loading(state.projects));

      // when projects of the user is being queried
      case ProjectStatus.retrieving:
        projects = await _tryGetProject(_authenticationRepository.token);
        print(projects.toString());
        return emit(
          projects != null
              ? ProjectState.ready(projects)
              : ProjectState.error(),
        );

      // when one of the project is being updated
      case ProjectStatus.updatingProject:
        final updatedProject = await _tryUpdateProject(
            _authenticationRepository.token, event.project);
        if (updatedProject != null) {
          List<Project> projects = state.projects;
          int updateIndex = projects.indexWhere(
            (e) => e.id == updatedProject.id,
          );
          projects.removeAt(updateIndex);
          projects.insert(updateIndex, updatedProject);
          return emit(ProjectState.ready(projects));
        }
        return emit(ProjectState.error());

      // when one of the userstory is being updated
      case ProjectStatus.updatingUserstory:
        final updatedUserstory = await _tryUpdateUserstory(
            _authenticationRepository.token, event.userstory);
        if (updatedUserstory != null) {
          List<Project> projects = state.projects;
          int projectIndex = projects.indexWhere((project) =>
              project.userstories.firstWhere(
                  (userstory) => userstory.id == updatedUserstory.id,
                  orElse: () => Userstory.empty) !=
              Userstory.empty);
          int updateIndex = projects[projectIndex]
              .userstories
              .indexWhere((userstory) => userstory.id == updatedUserstory.id);
          projects[projectIndex].userstories.removeAt(updateIndex);
          projects[projectIndex]
              .userstories
              .insert(updateIndex, updatedUserstory);
          return emit(ProjectState.ready(projects));
        }
        return emit(ProjectState.error());

      // when one of the userstory is being removed
      case ProjectStatus.removingUserstory:
        final removedUserstory = await _tryRemoveUserstory(
            _authenticationRepository.token, event.userstory);
        if (removedUserstory != null) {
          print('removedUserstory');
          print(removedUserstory);
          List<Project> projects = state.projects;
          int projectIndex = projects.indexWhere((project) =>
              project.userstories.firstWhere(
                  (userstory) => userstory.id == removedUserstory.id,
                  orElse: () => Userstory.empty) !=
              Userstory.empty);
          int updateIndex = projects[projectIndex]
              .userstories
              .indexWhere((userstory) => userstory.id == removedUserstory.id);
          projects[projectIndex].userstories.removeAt(updateIndex);
          return emit(ProjectState.ready(projects));
        }
        return emit(ProjectState.error());

      // when error is thrown
      case ProjectStatus.error:
        return emit(ProjectState.error());

      // when data is loaded and ready for other changes
      case ProjectStatus.ready:
        return emit(ProjectState.ready(state.projects));

      default:
        break;
    }
  }

  // These functions served manage the projects via requests to the backend
  Future<List<Project>?> _tryGetProject(String token) async {
    try {
      final projects = await _projectRepository.getProject(token);
      print("Project is : $projects");
      return projects;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<Project?> _tryUpdateProject(String token, Project project) async {
    try {
      print('_tryUpdateProject');
      final updatedProject =
          await _projectRepository.updateProject(token, project);
      return updatedProject;
    } catch (_) {
      return null;
    }
  }

  Future<Userstory?> _tryUpdateUserstory(
      String token, Userstory userstory) async {
    try {
      print('_tryUpdateUserstory');
      final updatedUserstory =
          await _projectRepository.updateUserstory(token, userstory);
      return Userstory(
        updatedUserstory!.id,
        title: updatedUserstory.title,
        status: updatedUserstory.status,
        tasks: userstory.tasks,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Userstory?> _tryRemoveUserstory(
      String token, Userstory userstory) async {
    try {
      print('_tryRemoveUserstory');
      final removedUserstory =
          await _projectRepository.removeUserstory(token, userstory);
      return removedUserstory;
    } catch (_) {
      return null;
    }
  }
}
