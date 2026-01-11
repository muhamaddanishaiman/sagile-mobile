import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:project_repository/project_repository.dart';
import 'package:sagile_mobile/project/bloc/project_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // Map<DateTime, List<dynamic>> exampleEvents = {
  //   // Map<DateTime, List<dynamic>> eventsExample = {
  //   DateTime.utc(DateTime.now().year, DateTime.now().month, 1): [
  //     {
  //       "title": "Task 1",
  //       "status": "Done",
  //     },
  //     {
  //       "title": "Task 2",
  //       "status": "In-Progress",
  //     },
  //   ],
  //   DateTime.utc(DateTime.now().year, DateTime.now().month, 8): [
  //     {
  //       "title": "Task 1",
  //       "status": "In-Progress",
  //     },
  //     {
  //       "title": "Task 1",
  //       "status": "In-Progress",
  //     },
  //     {
  //       "title": "Task 2",
  //       "status": "Planning",
  //     },
  //     {
  //       "title": "Task 3",
  //       "status": "Planning",
  //     },
  //   ],
  // };

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
                        Text('Calendar'),
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
                      final userstories = projects
                          .map((project) => project.userstories)
                          .expand((userstories) => userstories);
                      final tasks = userstories
                          .map((userstory) => userstory.tasks)
                          .expand((tasks) => tasks);
                      print('tasks');
                      print(tasks);
                      print('');

                      final startDates = tasks
                          .map((task) => task.startDate)
                          .where((date) => date != null)
                          .toSet();

                      final startEvents = startDates.map((date) {
                        return {
                          date!.toUtc(): tasks
                              .where((task) =>
                                  task.startDate != null &&
                                  task.startDate == date)
                              .map((task) => ({
                                    'label': 'startDate',
                                    'status': task.status.title,
                                    'title': task.title,
                                    'startDate': task.startDate,
                                    'endDate': task.endDate,
                                  }))
                              .toList()
                        };
                      }).toSet();

                      final endDates = tasks
                          .map((task) => task.endDate)
                          .where((date) => date != null)
                          .toSet();

                      final endEvents = endDates.map((date) {
                        return {
                          date!.toUtc(): tasks
                              .where((task) =>
                                  task.endDate != null && task.endDate == date)
                              .map((task) => ({
                                    'label': 'endDate',
                                    'status': task.status.title,
                                    'title': task.title,
                                    'startDate': task.startDate,
                                    'endDate': task.endDate,
                                  }))
                              .toList()
                        };
                      }).toSet();
                      
                      Map<DateTime, List<dynamic>> events = {};
                      if (startEvents.isNotEmpty) {
                         events.addAll(startEvents.reduce((value, element) => {...value, ...element}));
                      }
                      if (endEvents.isNotEmpty) {
                         final endMap = endEvents.reduce((value, element) => {...value, ...element});
                         // Merge maps carefully
                         endMap.forEach((key, value) {
                           if (events.containsKey(key)) {
                             events[key]!.addAll(value);
                           } else {
                             events[key] = value;
                           }
                         });
                      }

                      print('events count: ${events.length}');

                      switch (state.status) {
                        case ProjectStatus.loading:
                          return CircularProgressIndicator();
                        case ProjectStatus.ready:
                          return Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: TableCalendar(
                                    headerStyle: HeaderStyle(
                                      titleCentered: true,
                                      titleTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      weekendStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      markerDecoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        // shape: BoxShape.circle,
                                      ),
                                      // markersMaxCount: 1,
                                      weekendTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                    firstDay: DateTime(2000, 1, 1),
                                    lastDay: DateTime(DateTime.now().year + 25),
                                    focusedDay: _focusedDay,
                                    calendarFormat: _calendarFormat,
                                    availableCalendarFormats: {
                                      _calendarFormat: 'Month',
                                    },
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_selectedDay, day);
                                    },
                                    onDaySelected: (selectedDay, focusedDay) {
                                      if (!isSameDay(
                                          _selectedDay, selectedDay)) {
                                        setState(
                                          () {
                                            _selectedDay = selectedDay;
                                            _focusedDay = focusedDay;
                                          },
                                        );
                                      }
                                    },
                                    eventLoader: (day) {
                                      return events[day] ?? [];
                                    },
                                    calendarBuilders: CalendarBuilders(
                                      singleMarkerBuilder:
                                          (context, date, event) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            // color: Colors.green,
                                            color: (event as Map)['label'] ==
                                                    'startDate'
                                                ? Colors.green
                                                : Colors.red,
                                          ), //Change color
                                          width: 5.0,
                                          height: 5.0,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1.5),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                if (events[_selectedDay] != null)
                                  ...events[_selectedDay]!
                                      .map(
                                        (event) => Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: MaterialButton(
                                            onPressed: () {},
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
                                                      margin: EdgeInsets.zero,
                                                      color: Colors.blue,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    4.0),
                                                        child: Text(
                                                          '${event["status"]}',
                                                          style: TextStyle(
                                                              fontSize: 12,
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
                                                      '${event["title"]}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Card(
                                                      margin: EdgeInsets.zero,
                                                      color: Colors.green,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: Text(
                                                          '${DateFormat('dd/MM/yyyy').format(event["startDate"] as DateTime)}',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary),
                                                        ),
                                                      ),
                                                    ),
                                                    Card(
                                                      margin: EdgeInsets.zero,
                                                      color: Colors.red,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: Text(
                                                          '${DateFormat('dd/MM/yyyy').format(event["endDate"] as DateTime)}',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
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

// TableCalendar(
//   headerStyle: HeaderStyle(
//     titleCentered: true,
//     titleTextStyle: TextStyle(
//         color: Theme.of(context).colorScheme.onSurface),
//   ),
//   daysOfWeekStyle: DaysOfWeekStyle(
//     weekdayStyle: TextStyle(
//         color: Theme.of(context).colorScheme.onSurface),
//     weekendStyle: TextStyle(
//         color: Theme.of(context).colorScheme.onSurface),
//   ),
//   calendarStyle: CalendarStyle(
//     markerDecoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.primary,
//         shape: BoxShape.circle),
//     markersMaxCount: 1,
//     weekendTextStyle: TextStyle(
//         color: Theme.of(context).colorScheme.onSurface),
//   ),
//   firstDay: DateTime(DateTime.now().year - 1),
//   lastDay: DateTime(DateTime.now().year + 1),
//   focusedDay: _focusedDay,
//   calendarFormat: _calendarFormat,
//   availableCalendarFormats: {
//     _calendarFormat: 'Month',
//   },
//   selectedDayPredicate: (day) {
//     return isSameDay(_selectedDay, day);
//   },
//   onDaySelected: (selectedDay, focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(
//         () {
//           _selectedDay = selectedDay;
//           _focusedDay = focusedDay;
//         },
//       );
//     }
//   },
//   eventLoader: (day) {
//     return exampleEvents[day] ?? [];
//   },
// ),
