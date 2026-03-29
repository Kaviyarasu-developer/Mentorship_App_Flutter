import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/screens/user_screens/mentor_profile_screen.dart';
import 'package:practice_app/screens/user_screens/staff_profile_screen.dart';
import 'package:practice_app/screens/user_screens/student_profile_screen.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';

class PeopleSearchScreen extends StatefulWidget {
  const PeopleSearchScreen({super.key});

  @override
  State<PeopleSearchScreen> createState() => _PeopleSearchScreenState();
}

class _PeopleSearchScreenState extends State<PeopleSearchScreen> {
  List<UserModel> students = [];
  List<UserModel> mentors = [];
  List<UserModel> staff = [];

  bool isOwner = false;

  String get userRole => SessionService.role ?? "";

  int get userId => SessionService.userId ?? 0;

  String selectedFilter = "ALL";

  bool loading = true;

  // ---------------- FETCH STUDENTS ----------------

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/account/STD/getall"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        students = data
            .map(
              (e) => UserModel.fromJson({
                "id": e["id"],
                "name": e["name"],
                "role": "STD",
                "username": e["username"],
              }),
            )
            .toList();
      }
    } catch (e) {
      debugPrint("students error: $e");
    }
  }

  // ---------------- FETCH MENTORS ----------------
  Future<void> fetchMentors() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/account/MENTOR/getall"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        mentors = data
            .map(
              (e) => UserModel.fromJson({
                "id": e["id"],
                "name": e["name"],
                "role": "MENTOR",
                "username": e["username"],
              }),
            )
            .toList();
      }
    } catch (e) {
      debugPrint("mentors error: $e");
    }
  }

  // ---------------- FETCH STAFF ----------------

  Future<void> fetchStaff() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/account/STAFF/getall"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        staff = data
            .map(
              (e) => UserModel.fromJson({
                "id": e["id"],
                "name": e["name"],
                "role": "STAFF",
                "username": e["username"],
              }),
            )
            .toList();
      }
    } catch (e) {
      debugPrint("staff error: $e");
    }
  }

  // ---------------- LOAD ALL ----------------

  Future<void> loadAllUsers() async {
    await Future.wait([fetchStudents(), fetchMentors(), fetchStaff()]);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAllUsers();
  }

  // ---------------- FILTERED LIST ----------------

  List<UserModel> get currentList {
    if (selectedFilter == "STD") return students;

    if (selectedFilter == "MENTOR") return mentors;

    if (selectedFilter == "STAFF") return staff;

    return [...students, ...mentors, ...staff];
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildFilterBar(),

        Expanded(
          child: currentList.isEmpty
              ? const Center(child: Text("No Peoples Available"))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),

                  itemCount: currentList.length,

                  itemBuilder: (context, index) {
                    final person = currentList[index];

                    return _buildPersonCard(person);
                  },
                ),
        ),
      ],
    );
  }

  // ---------------- FILTER BAR ----------------

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Wrap(
        spacing: 8,

        children: [
          _buildFilterChip("ALL"),
          _buildFilterChip("STD"),
          _buildFilterChip("MENTOR"),
          _buildFilterChip("STAFF"),
        ],
      ),
    );
  }

  // ---------------- PERSON CARD ----------------

  Widget _buildPersonCard(UserModel person) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () {
        if (userId == person.id) {
          isOwner = true;
        } else {
          isOwner = false;
        }

        if (person.role == "MENTOR") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorProfileScreen(
                id: person.id,
                name: person.name,
                username: person.username,
                role: person.role,
                isOwner: isOwner,
              ),
            ),
          );
        } else if (person.role == "STD") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentProfileScreen(
                id: person.id,
                name: person.name,
                username: person.username,
                role: person.role,
                isOwner: isOwner,
              ),
            ),
          );
        } else if (person.role == "STAFF") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffProfileScreen(
                id: person.id,
                name: person.name,
                username: person.username,
                role: person.role,
                isOwner: isOwner,
              ),
            ),
          );
        }
      },

      child: Card(
        elevation: 4,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              const CircleAvatar(
                radius: 35,
                foregroundImage: AssetImage(
                  "assets/images/profile_placeholder_image.png",
                ),
              ),

              const SizedBox(height: 10),

              Text(
                person.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "@${person.username}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 6),

              Text(
                person.role,
                style: TextStyle(
                  color: _getRoleColor(person.role),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              ElevatedButton(onPressed: () {}, child: const Text("Connect")),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- FILTER CHIP ----------------

  Widget _buildFilterChip(String role) {
    return FilterChip(
      label: Text(role),

      selected: selectedFilter == role,

      onSelected: (_) {
        setState(() {
          selectedFilter = role;
        });
      },
    );
  }

  // ---------------- ROLE COLOR ----------------

  Color _getRoleColor(String role) {
    switch (role) {
      case "STD":
        return Colors.blue;

      case "MENTOR":
        return Colors.green;

      case "STAFF":
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }
}
