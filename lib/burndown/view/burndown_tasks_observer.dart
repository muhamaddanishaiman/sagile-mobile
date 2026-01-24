import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sagile_mobile/burndown/bloc/burndown_bloc.dart';

class BurndownTasksObserver extends StatelessWidget {
  const BurndownTasksObserver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BurndownBloc, BurndownState>(
      builder: (context, state) {
        if (state is BurndownLoaded) {
          final tasks = state.data['tasks'] as List<dynamic>? ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Task')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Assigned To')),
                DataColumn(label: Text('Status')),
              ],
              rows: tasks.map<DataRow>((task) {
                final t = task as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(t['title']?.toString() ?? '')),
                  DataCell(Text(t['description']?.toString() ?? '')),
                  DataCell(Text(t['assigned_to']?.toString() ?? '')),
                  DataCell(Text(t['status']?.toString() ?? '')),
                ]);
              }).toList(),
            ),
          );
        } else if (state is BurndownLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BurndownError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
