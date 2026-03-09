import 'package:flutter/material.dart';
import 'package:practice_app/screens/admin_screens/clgmng_screen.dart';
import 'package:practice_app/screens/anouncements_screen.dart';
import 'package:practice_app/screens/login_screen.dart';

class AdminpageScreen extends StatefulWidget {
  const AdminpageScreen({super.key});

  @override
  State<AdminpageScreen> createState() => _AdminpageScreenState();
}

class _AdminpageScreenState extends State<AdminpageScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [ClgmngScreen(), AnouncementsScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.teal,

        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Colleges"),

          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: "Announcements",
          ),
        ],
      ),
    );
  }
}
