part of 'burndown_bloc.dart';

abstract class BurndownState extends Equatable {
  const BurndownState();
  
  @override
  List<Object> get props => [];
}

class BurndownInitial extends BurndownState {}

class BurndownLoading extends BurndownState {}

class BurndownLoaded extends BurndownState {
  const BurndownLoaded(this.data);

  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class BurndownError extends BurndownState {
  const BurndownError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
