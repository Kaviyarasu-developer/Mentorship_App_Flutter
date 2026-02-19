import 'package:flutter/material.dart';
import 'package:practice_app/screens/anouncements_screen.dart';
import 'package:practice_app/screens/user_screens/community_screen.dart';
import 'package:practice_app/screens/user_screens/home_screen.dart';
import 'package:practice_app/screens/user_screens/people_search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    HomeScreen(),
    PeopleSearchScreen(),
    CommunityScreen(),
    AnouncementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Screen"),
        backgroundColor: Colors.grey,
        actions: [BackButton(onPressed: () => Navigator.pop(context))],
      ),
      drawer: Drawer(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: "Search",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: "Anouncements",
          ),
        ],
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
