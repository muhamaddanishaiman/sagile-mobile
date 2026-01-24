import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:sagile_mobile/burndown/bloc/burndown_bloc.dart';
import 'package:sagile_mobile/burndown/view/burndown_table_view.dart';

class BurndownPage extends StatelessWidget {
  const BurndownPage({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BurndownBloc>(
      create: (context) => _createBloc(context),
      child: BurndownChartView(projectId: projectId),
    );
  }

  BurndownBloc _createBloc(BuildContext context) {
    return BurndownBloc(
      projectRepository: context.read<ProjectRepository>(),
      authenticationRepository: context.read<AuthenticationRepository>(),
    )..add(FetchBurndownData(projectId: projectId));
  }
}

class BurndownChartView extends StatelessWidget {
  const BurndownChartView({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<BurndownBloc, BurndownState>(
        builder: _buildBody,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Burndown Chart'),
      actions: [
        IconButton(
          onPressed: () => _refresh(context),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  void _refresh(BuildContext context) {
    context.read<BurndownBloc>().add(FetchBurndownData(projectId: projectId));
  }

  Widget _buildBody(BuildContext context, BurndownState state) {
    if (state is BurndownLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is BurndownError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    if (state is BurndownLoaded) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSprintSelector(context, state),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 24),
            _buildChart(context, state.data),
            const SizedBox(height: 16),
            const Expanded(
              child: SingleChildScrollView(
                child: BurndownTableView(),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('No data'));
  }

  Widget _buildSprintSelector(BuildContext context, BurndownLoaded state) {
    final sprints = state.sprints.cast<Sprint>();
    final currentSprintId = state.data['sprint_id'] as int?;

    if (sprints.isEmpty) {
      return Text(
        "Sprint: ${state.data['sprint_name']}",
        style: Theme.of(context).textTheme.titleLarge,
      );
    }

    return DropdownButton<int>(
      value: currentSprintId,
      hint: const Text("Select Sprint"),
      isExpanded: true,
      items: sprints.map((s) => _buildSprintItem(s)).toList(),
      onChanged: (val) => _onSprintChanged(context, val),
    );
  }

  DropdownMenuItem<int> _buildSprintItem(Sprint s) {
    return DropdownMenuItem<int>(
      value: s.sprintId,
      child: Text(
        "${s.sprintName} (${s.activeSprint == 1 ? 'Active' : 'Inactive'})",
        style: TextStyle(
          fontWeight: s.activeSprint == 1 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _onSprintChanged(BuildContext context, int? sprintId) {
    if (sprintId != null) {
      context.read<BurndownBloc>().add(
        FetchBurndownData(projectId: projectId, sprintId: sprintId),
      );
    }
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        LegendItem(color: Colors.blue, text: "Ideal"),
        SizedBox(width: 16),
        LegendItem(color: Colors.red, text: "Actual"),
      ],
    );
  }

  Widget _buildChart(BuildContext context, Map<String, dynamic> data) {
    final idealData = List<double>.from((data['ideal_data'] as List).map((e) => (e as num).toDouble()));
    final actualData = List<double>.from((data['actual_data'] as List).map((e) => (e as num).toDouble()));

    return Expanded(
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
            _buildLine(idealData, Colors.blue, false),
            _buildLine(actualData, Colors.red, true),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<double> data, Color color, bool showDots) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: false,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: showDots),
    );
  }
}

class LegendItem extends StatelessWidget {
  const LegendItem({super.key, required this.color, required this.text});
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
