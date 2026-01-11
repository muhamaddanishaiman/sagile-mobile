import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_repository/project_repository.dart';
import 'package:sagile_mobile/project/bloc/project_bloc.dart';
import 'package:sagile_mobile/userstory/view/userstory_modal.dart';

class UserstoryPage extends StatefulWidget {
  const UserstoryPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const UserstoryPage());
  }

  @override
  State<UserstoryPage> createState() => _UserstoryPageState();
}

class _UserstoryPageState extends State<UserstoryPage> {
  @override
  Widget build(BuildContext context) {
    final _navigator = Navigator.of(context);

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
                        Text('Tasks'),
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
                      final projects = state.projects;
                      switch (state.status) {
                        case ProjectStatus.loading:
                          return CircularProgressIndicator();
                        case ProjectStatus.ready:
                          return Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                ...projects
                                    .map(
                                      (project) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: ExpansionTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          textColor: Colors.black,
                                          initiallyExpanded:
                                              project.userstories.length > 0,
                                          title: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Text(
                                              '${project.title}',
                                            ),
                                          ),
                                          expandedCrossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ...project.userstories
                                                .map(
                                                  (userstory) => Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      side: BorderSide(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    child: MaterialButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              UserstoryModal(
                                                            userstoryId:
                                                                userstory.id,
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Card(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          4.0),
                                                              color:
                                                                  Colors.blue,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                                child: Text(
                                                                  '${userstory.status.title}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary
                                                                      // fontWeight: FontWeight.bold,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              '${userstory.title}',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                // fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            ...userstory.tasks
                                                                .map(
                                                              (task) => Card(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            4),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  side:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Card(
                                                                            margin:
                                                                                EdgeInsets.zero,
                                                                            color:
                                                                                Colors.blue,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                                              child: Text(
                                                                                '${task.status.title}',
                                                                                style: TextStyle(
                                                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${task.title}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              // fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        children: [
                                                                          Card(
                                                                            margin:
                                                                                EdgeInsets.zero,
                                                                            color:
                                                                                Colors.green,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                                              child: Text(
                                                                                '${DateFormat('dd/MM/yyyy').format(task.startDate!)}',
                                                                                style: TextStyle(
                                                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Card(
                                                                            margin:
                                                                                EdgeInsets.zero,
                                                                            color:
                                                                                Colors.red,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                                              child: Text(
                                                                                '${DateFormat('dd/MM/yyyy').format(task.endDate!)}',
                                                                                style: TextStyle(
                                                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // ),
                                                )
                                                .toList(),
                                            // Add User Story button removed for view-only mode
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
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
