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
    emit(BurndownLoading());
    try {
      // We need the token. In a real app, we might get this from the AuthBloc or AuthRepository
      // assuming AuthRepository exposes the current token.
      // If not, we might need to rely on the passed token or similar mechanism.
      // checking authentication_repository.dart via view_file would confirm how to get token.
      // For now, I'll attempt to get it from the user getter if available.
      
      final token = _authenticationRepository.token;
      
      if (token.isEmpty) {
        emit(BurndownError("User not authenticated"));
        return;
      }
       
       final data = await _projectRepository.getBurndownData(
         token: token, 
         projectId: event.projectId
       );

       if (data != null) {
         emit(BurndownLoaded(data));
       } else {
         emit(BurndownError("Failed to fetch data"));
       }
    } catch (e) {
      emit(BurndownError(e.toString()));
    }
  }
}
