import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sagile_mobile/dashboard/cubit/dashboard_cubit.dart';
import 'package:sagile_mobile/calendar/view/calendar_page.dart';
import 'package:sagile_mobile/project/view/project_page.dart';
import 'package:sagile_mobile/home/view/settings_page.dart';
import 'package:sagile_mobile/team/view/team_page.dart';
import 'package:sagile_mobile/userstory/view/userstory_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class TabPage {
  TabPage({required this.page, required this.tab});
  final Widget page;
  final SalomonBottomBarItem tab;
}

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => DashboardPage());
  }

  final List<TabPage> _tabPages = [
    TabPage(
      page: const UserstoryPage(),
      tab: SalomonBottomBarItem(
        icon: const Icon(Icons.home),
        title: const Text("Home"),
        selectedColor: Colors.purple,
      ),
    ),
    TabPage(
      page: const CalendarPage(),
      tab: SalomonBottomBarItem(
        icon: const Icon(Icons.calendar_month),
        title: const Text("Calendar"),
        selectedColor: Colors.orange,
      ),
    ),
    TabPage(
      page: const ProjectPage(),
      tab: SalomonBottomBarItem(
        icon: const Icon(Icons.folder),
        title: const Text("Projects"),
        selectedColor: Colors.pink,
      ),
    ),
    TabPage(
      page: const TeamPage(),
      tab: SalomonBottomBarItem(
        icon: const Icon(Icons.people),
        title: const Text("Team"),
        selectedColor: Colors.blueAccent,
      ),
    ),
    TabPage(
      page: const SettingsPage(),
      tab: SalomonBottomBarItem(
        icon: const Icon(Icons.person),
        title: const Text("Profile"),
        selectedColor: Colors.teal,
      ),
    ),
  ];

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, int>(
      builder: (context, state) {
        return Theme(
          data: ThemeData.light(),
          child: Scaffold(
            body: widget._tabPages[state].page,
            // body: tabPageFunction(context, _selectedIndex),
            bottomNavigationBar: SalomonBottomBar(
              currentIndex: state,
              selectedItemColor: const Color(0xff6200ee),
              unselectedItemColor: const Color(0xff757575),
              onTap: (index) {
                context.read<DashboardCubit>().set(index);
              },
              items: widget._tabPages.map((e) => e.tab).toList(),
            ),
          ),
        );
      },
    );
  }
}

// Widget tabPageFunction(BuildContext context, int index) {
//   final _tabPages = [
//     // const HomePage(),
//     const ProjectPage(),
//     // const CalendarPage(),
//     const SettingsPage(),
//   ];
//   return _tabPages[index];
// }

// final _navBarItems = [
//   // SalomonBottomBarItem(
//   //   icon: const Icon(Icons.home),
//   //   title: const Text("Home"),
//   //   selectedColor: Colors.purple,
//   // ),
//   SalomonBottomBarItem(
//     icon: const Icon(Icons.folder),
//     title: const Text("Projects"),
//     selectedColor: Colors.pink,
//   ),
//   // SalomonBottomBarItem(
//   //   icon: const Icon(Icons.calendar_month),
//   //   title: const Text("Calendar"),
//   //   selectedColor: Colors.orange,
//   // ),
//   SalomonBottomBarItem(
//     icon: const Icon(Icons.person),
//     title: const Text("Profile"),
//     selectedColor: Colors.teal,
//   ),
// ];
