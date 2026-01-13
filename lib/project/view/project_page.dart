import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';
import 'package:sagile_mobile/project/bloc/project_bloc.dart';
import 'package:sagile_mobile/project/view/project_modal.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sagile_mobile/authentication/authentication.dart';
// import 'package:sagile_mobile/home/view/custom_widgets.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ProjectPage());
  }

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Projects'),
                        IconButton(
                            onPressed: () {
                              context.read<ProjectBloc>()
                                ..add(
                                    ProjectStatusChanged(ProjectStatus.loading))
                                ..add(ProjectStatusChanged(
                                    ProjectStatus.retrieving));
                            },
                            icon: Icon(Icons.refresh))
                      ],
                    ),
                  ),
                  Divider(),
                  BlocBuilder<ProjectBloc, ProjectState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      switch (state.status) {
                        case ProjectStatus.loading:
                          return CircularProgressIndicator();
                        case ProjectStatus.ready:
                          return Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                context.read<ProjectBloc>()
                                  ..add(ProjectStatusChanged(ProjectStatus.loading))
                                  ..add(ProjectStatusChanged(ProjectStatus.retrieving));
                              },
                              child: ListView(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  ...state.projects
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                            onPressed: () {
                                              // Open project details
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ProjectModal(
                                                  projectId: e.id,
                                                ),
                                              );
                                            },
                                            child: ListTile(
                                              title: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16.0),
                                                child: Text(
                                                  '${e.title}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              subtitle: Text(
                                                e.description.isNotEmpty 
                                                  ? e.description 
                                                  : "No description",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),
                          );
                        case ProjectStatus.error:
                          return Text('error');
                        default:
                          break;
                      }
                      return Text('unauth');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
