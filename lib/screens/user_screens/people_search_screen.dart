import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class PeopleSearchScreen extends StatefulWidget {
  const PeopleSearchScreen({super.key});

  @override
  State<PeopleSearchScreen> createState() => _PeopleSearchScreen();
}

class _PeopleSearchScreen extends State<PeopleSearchScreen> {
  List<Map<String, String>> students = [];
  List<Map<String, String>> mentors = [];
  List<Map<String, String>> staff = [];
  final loginuser = Hive.box("users");
  String? get userRole => loginuser.get("role");
  String selectedFilter = "ALL";

  // ---------------- FETCH STUDENTS ----------------
  Future<void> fetchStudents() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/app/students/getall"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      setState(() {
        students = data
            .map(
              (e) => {
                "name": e["name"].toString(),
                "role": "STD",
                "username": e["username"].toString(),
              },
            )
            .toList();
      });
    }
  }

  // ---------------- FETCH MENTORS ----------------
  Future<void> fetchMentors() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/app/mentor/getall"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      setState(() {
        mentors = data
            .map(
              (e) => {
                "name": e["name"].toString(),
                "role": "MENTOR",
                "username": e["username"].toString(),
              },
            )
            .toList();
      });
    }
  }

  // ---------------- FETCH STAFF ----------------
  Future<void> fetchStaff() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/app/staff/getall"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print(response.body);
      setState(() {
        staff = data
            .map(
              (e) => {
                "name": e["clgname"].toString(),
                "role": "STAFF",
                "username": e["username"].toString(),
              },
            )
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchMentors();
    fetchStaff();
  }

  @override
  Widget build(BuildContext context) {
    // ---- Merge all lists if ALL selected ----
    List<Map<String, String>> currentList;

    if (selectedFilter == "STD") {
      currentList = students;
    } else if (selectedFilter == "MENTOR") {
      currentList = mentors;
    } else if (selectedFilter == "STAFF") {
      currentList = staff;
    } else {
      currentList = [...students, ...mentors, ...staff];
    }

    if (currentList.isEmpty) {
      return Column(
        children: [
          // ---------------- FILTER BUTTONS ----------------
          Padding(
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
          ),
          const Center(child: Text("No Peoples Available")),
        ],
      );
    }

    return Column(
      children: [
        // ---------------- FILTER BUTTONS ----------------
        Padding(
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
        ),

        // ---------------- GRID VIEW ----------------
        Expanded(
          child: GridView.builder(
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

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 35),
                      const SizedBox(height: 10),
                      Text(
                        person["name"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        person["username"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        person["role"] ?? "",
                        style: TextStyle(
                          color: _getRoleColor(person["role"]),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Connect"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- FILTER CHIP BUILDER ----------------
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
  Color _getRoleColor(String? role) {
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
