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
  int _selected_index = 0;
  final List<Widget> _screens = [ClgmngScreen(), AnouncementsScreen()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          actions: [
            BackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: _screens[_selected_index],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _selected_index = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.announcement), label: ""),
          ],
        ),
      ),
    );
  }
}
