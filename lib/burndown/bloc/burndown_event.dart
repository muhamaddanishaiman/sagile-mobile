part of 'burndown_bloc.dart';

abstract class BurndownEvent extends Equatable {
  const BurndownEvent();

  @override
  @override
  List<Object?> get props => [];
}

class FetchBurndownData extends BurndownEvent {
  const FetchBurndownData({required this.projectId, this.sprintId});

  final int projectId;
  final int? sprintId;

  @override
  List<Object?> get props => [projectId, sprintId];
}
