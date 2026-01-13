import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:sagile_mobile/burndown/bloc/burndown_bloc.dart';

class BurndownPage extends StatelessWidget {
  const BurndownPage({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    print("DEBUG: Building BurndownPage for projectId: $projectId");
    return BlocProvider<BurndownBloc>(
      create: (context) {
        print("DEBUG: Creating BurndownBloc");
        try {
          final projectRepo = context.read<ProjectRepository>();
          final authRepo = context.read<AuthenticationRepository>();
          print("DEBUG: Repos found. AuthToken: ${authRepo.token}");
          
          return BurndownBloc(
            projectRepository: projectRepo,
            authenticationRepository: authRepo,
          )..add(FetchBurndownData(projectId: projectId));
        } catch (e) {
          print("DEBUG: Error creating BurndownBloc: $e");
          rethrow;
        }
      },
      child: _BurndownView(projectId: projectId),
    );
  }
}

class _BurndownView extends StatelessWidget {
  const _BurndownView({required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Burndown Chart'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<BurndownBloc>().add(FetchBurndownData(projectId: projectId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<BurndownBloc, BurndownState>(
        builder: (context, state) {
          if (state is BurndownLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BurndownError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BurndownLoaded) {
            final data = state.data;
            final idealData = List<double>.from((data['ideal_data'] as List).map((e) => (e as num).toDouble()));
            final actualData = List<double>.from((data['actual_data'] as List).map((e) => (e as num).toDouble()));
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Sprint: ${data['sprint_name']}", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendItem(color: Colors.blue, text: "Ideal"),
                      const SizedBox(width: 16),
                      _LegendItem(color: Colors.red, text: "Actual"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: idealData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: actualData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: false,
                            color: Colors.red,
                            barWidth: 2,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
