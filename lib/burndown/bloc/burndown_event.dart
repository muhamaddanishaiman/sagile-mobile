part of 'burndown_bloc.dart';

abstract class BurndownEvent extends Equatable {
  const BurndownEvent();

  @override
  List<Object> get props => [];
}

class FetchBurndownData extends BurndownEvent {
  const FetchBurndownData({required this.projectId});

  final int projectId;

  @override
  List<Object> get props => [projectId];
}
