import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;

import 'package:practice_app/screens/anouncements_screen.dart';
import 'package:practice_app/screens/login_screen.dart';
import 'package:practice_app/screens/user_screens/community_screen.dart';
import 'package:practice_app/screens/user_screens/home_screen.dart';
import 'package:practice_app/screens/user_screens/mentor_profile_screen.dart';
import 'package:practice_app/screens/user_screens/people_search_screen.dart';
import 'package:practice_app/screens/user_screens/staff_profile_screen.dart';
import 'package:practice_app/screens/user_screens/student_profile_screen.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final int? _id = SessionService.userId;
  final String? _role = SessionService.role;
  final String? _username = SessionService.username;
  final String? _name = SessionService.name;

  // ---------------- PROFILE MENU ----------------

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 20, 0),
      items: [
        PopupMenuItem(
          enabled: false,

          child: Column(
            children: [
              GestureDetector(
                onTap: _openProfile,

                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person),
                      //backgroundImage: NetworkImage(""),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _username ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      _role ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Divider(),

              if (_role == "STAFF") ...[
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Add Student"),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddStudentDialog();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Add Mentor"),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddMentorDialog();
                  },
                ),
              ],

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- OPEN PROFILE ----------------

  void _openProfile() {
    if (_role == "STD") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentProfileScreen(
            id: _id ?? 0,
            name: _name ?? "",
            username: _username ?? "",
            role: _role ?? "",
            isOwner: true,
          ),
        ),
      );
    } else if (_role == "MENTOR") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorProfileScreen(
            id: _id ?? 0,
            name: _name ?? "",
            username: _username ?? "",
            role: _role ?? "",
            isOwner: true,
          ),
        ),
      );
    } else if (_role == "STAFF") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StaffProfileScreen(
            id: _id ?? 0,
            name: _name ?? "",
            username: _username ?? "",
            role: _role ?? "",
            isOwner: true,
          ),
        ),
      );
    }
  }

  // ---------------- ADD STUDENT ----------------

  void _showAddStudentDialog() {
    final formKey = GlobalKey<FormState>();

    final rollnoController = TextEditingController();
    final nameController = TextEditingController();
    final deptController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final clgcodeController = TextEditingController();

    Future<void> createStudent() async {
      try {
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/account/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "rollno": int.parse(rollnoController.text),
            "name": nameController.text,
            "dept": deptController.text,
            "username": usernameController.text,
            "password": passwordController.text,
            "clgcode": int.parse(clgcodeController.text),
            "role": "STD",
          }),
        );
        if (response.statusCode == 200) {}
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Server error")));
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Student"),

          content: SingleChildScrollView(
            child: Form(
              key: formKey,

              child: Column(
                children: [
                  TextFormField(
                    controller: rollnoController,
                    validator: RequiredValidator(
                      errorText: "Enter Roll no",
                    ).call,
                    decoration: const InputDecoration(labelText: "Roll no"),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: nameController,
                    validator: RequiredValidator(errorText: "Enter Name").call,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: deptController,
                    validator: RequiredValidator(
                      errorText: "Enter Department",
                    ).call,
                    decoration: const InputDecoration(labelText: "Department"),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: clgcodeController,
                    validator: RequiredValidator(
                      errorText: "Enter College Code",
                    ).call,
                    decoration: const InputDecoration(
                      labelText: "College Code",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: usernameController,
                    validator: RequiredValidator(
                      errorText: "Enter Username",
                    ).call,
                    decoration: const InputDecoration(
                      labelText: "Create Username",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: RequiredValidator(
                      errorText: "Enter Password",
                    ).call,
                    decoration: const InputDecoration(
                      labelText: "Create Password",
                    ),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await createStudent();

                  if (!mounted) return;

                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- ADD MENTOR ----------------

  void _showAddMentorDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final clgcodeController = TextEditingController();

    Future<void> createMentor() async {
      try {
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/account/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": nameController.text,
            "username": usernameController.text,
            "password": passwordController.text,
            "clgcode": int.parse(clgcodeController.text),
            "role": "MENTOR",
          }),
        );
        if (response.statusCode == 200) {}
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Server error")));
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Mentor"),

          content: SingleChildScrollView(
            child: Form(
              key: formKey,

              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    validator: RequiredValidator(errorText: "Enter Name").call,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: clgcodeController,
                    validator: RequiredValidator(
                      errorText: "Enter College Code",
                    ).call,
                    decoration: const InputDecoration(
                      labelText: "College Code",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: usernameController,
                    validator: RequiredValidator(
                      errorText: "Enter Username",
                    ).call,
                    decoration: const InputDecoration(
                      labelText: "Create Username",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: RequiredValidator(
                      errorText: "Enter Password",
                    ).call,
                    decoration: const InputDecoration(
                      labelText: "Create Password",
                    ),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await createMentor();

                  if (!mounted) return;

                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- LOGOUT ----------------

  void _confirmLogout() {
    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Logout"),

        content: const Text("Are you sure you want to logout?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    SessionService.logout();
  }

  // ---------------- PAGES ----------------

  final List<Widget> pages = const [
    HomeScreen(),
    PeopleSearchScreen(),
    CommunityScreen(),
    AnnouncementScreen(),
  ];

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mentorship App"),
        backgroundColor: Colors.indigo,

        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person),
                // backgroundImage: NetworkImage(
                //   "https://i.pravatar.cc/150?img=4",
                // ),
              ),

              onPressed: () => _showProfileMenu(context),
            ),
          ),
        ],
      ),

      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.indigo,

        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: "Search",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),

          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: "Announcements",
          ),
        ],
      ),
    );
  }
}
