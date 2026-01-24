import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:project_repository/project_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';

part 'burndown_event.dart';
part 'burndown_state.dart';

class BurndownBloc extends Bloc<BurndownEvent, BurndownState> {
  BurndownBloc({
    required ProjectRepository projectRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _projectRepository = projectRepository,
        _authenticationRepository = authenticationRepository,
        super(BurndownInitial()) {
    on<FetchBurndownData>(_onFetchBurndownData);
  }

  final ProjectRepository _projectRepository;
  final AuthenticationRepository _authenticationRepository;

  Future<void> _onFetchBurndownData(
    FetchBurndownData event,
    Emitter<BurndownState> emit,
  ) async {
    // Preserve sprints if available
    List<dynamic> sprints = [];
    if (state is BurndownLoaded) {
      sprints = (state as BurndownLoaded).sprints;
    }

    emit(BurndownLoading());
    try {
      final token = _authenticationRepository.token;
      
      if (token.isEmpty) {
        emit(const BurndownError("User not authenticated"));
        return;
      }

      // Fetch sprints if not already loaded
      if (sprints.isEmpty) {
        final fetchedSprints = await _projectRepository.getSprints(
          token: token,
          projectId: event.projectId,
        );
        if (fetchedSprints != null) {
          sprints = fetchedSprints;
        }
      }
       
       final data = await _projectRepository.getBurndownData(
         token: token, 
         projectId: event.projectId,
         sprintId: event.sprintId,
       );

       if (data != null) {
         emit(BurndownLoaded(
           data, 
           sprints: sprints, 
           selectedSprintId: event.sprintId,
         ));
       } else {
         emit(const BurndownError("Failed to fetch data"));
       }
    } catch (e) {
      emit(BurndownError(e.toString()));
    }
  }
}
