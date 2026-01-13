import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';
import 'package:sagile_mobile/authentication/authentication.dart';
import 'package:sagile_mobile/home/view/custom_widgets.dart';
import 'package:sagile_mobile/project/bloc/project_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<ProjectBloc>().add(ProjectStatusChanged(ProjectStatus.loading));
    context.read<ProjectBloc>().add(ProjectStatusChanged(ProjectStatus.retrieving));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProjectBloc>().add(ProjectStatusChanged(ProjectStatus.loading));
          context.read<ProjectBloc>().add(ProjectStatusChanged(ProjectStatus.retrieving));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SingleSection(
                          title: "Home",
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                              child: Divider(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "My Tasks",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            BlocBuilder<ProjectBloc, ProjectState>(
                              builder: (context, state) {
                                switch (state.status) {
                                  case ProjectStatus.loading:
                                    return const Center(child: CircularProgressIndicator());
                                  case ProjectStatus.ready:
                                    if (state.projects.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text("No projects found."),
                                      );
                                    }
                                    final allTasks = state.projects
                                        .expand((p) => p.userstories)
                                        .expand((u) => u.tasks)
                                        .toList();
                                    
                                    if (allTasks.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text("No tasks assigned."),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: allTasks.length > 5 ? 5 : allTasks.length,
                                      itemBuilder: (context, index) {
                                        final task = allTasks[index];
                                        return ListTile(
                                          title: Text(task.title),
                                          subtitle: Text(task.status.title),
                                          trailing: Text(
                                            task.endDate != null 
                                              ? "${task.endDate!.day}/${task.endDate!.month}/${task.endDate!.year}"
                                              : "-"
                                          ),
                                        );
                                      },
                                    );
                                  case ProjectStatus.error:
                                    return const Center(child: Text("Failed to load tasks"));
                                  default:
                                    return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
