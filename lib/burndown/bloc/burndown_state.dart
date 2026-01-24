part of 'burndown_bloc.dart';

abstract class BurndownState extends Equatable {
  const BurndownState();
  
  @override
  @override
  List<Object?> get props => [];
}

class BurndownInitial extends BurndownState {}

class BurndownLoading extends BurndownState {}

class BurndownLoaded extends BurndownState {
  const BurndownLoaded(this.data, {this.sprints = const [], this.selectedSprintId});

  final Map<String, dynamic> data;
  final List<dynamic> sprints;
  final int? selectedSprintId;

  @override
  List<Object?> get props => [data, sprints, selectedSprintId];
    
  BurndownLoaded copyWith({
    Map<String, dynamic>? data,
    List<dynamic>? sprints,
    int? selectedSprintId,
  }) {
    return BurndownLoaded(
      data ?? this.data,
      sprints: sprints ?? this.sprints,
      selectedSprintId: selectedSprintId ?? this.selectedSprintId,
    );
  }
}

class BurndownError extends BurndownState {
  const BurndownError(this.message);

  final String message;

  @override
  @override
  List<Object?> get props => [message];
}
