import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/screens/login_screen.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';

class PrincepalMainScreen extends StatefulWidget {
  const PrincepalMainScreen({super.key});

  @override
  State<PrincepalMainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<PrincepalMainScreen> {
  List<Map<String, String>> staffs = [];
  final formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final clgcodeController = TextEditingController();
  String? role = SessionService.role;
  String? username = SessionService.username;

  void _showProfileMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(
            button.size.bottomRight(Offset.zero),
            ancestor: overlay,
          ),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=4",
                ),
              ),
              const SizedBox(height: 10),
              Text(
                username ?? "DEFAULT",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                role ?? "DEFAULT",
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(),
              Builder(
                builder: (context) {
                  if (role != "STD") {
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text("Add Staff"),
                          onTap: () {
                            _showAddStaffDialog();
                          },
                        ),
                      ],
                    );
                  } else {
                    return Column();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  _confirmLogout();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddStaffDialog() {
    Future<void> createStudent() async {
      try {
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/account/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": nameController.text,
            "dept": deptController.text,
            "username": usernameController.text,
            "password": passwordController.text,
            "clgcode": int.parse(clgcodeController.text),
            "role": "STAFF",
          }),
        );
        if (response.statusCode == 200) {
          // refresh list
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Server error")));
      }
    }

    void createaction() {
      if (formkey.currentState!.validate()) {
        createStudent();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Staff"),
          content: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: RequiredValidator(errorText: "Enter Name").call,
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Staff Name"),
                  ),

                  SizedBox(height: 10),

                  TextFormField(
                    validator: RequiredValidator(
                      errorText: "Enter Department",
                    ).call,
                    controller: deptController,
                    decoration: InputDecoration(labelText: "Department"),
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    validator: RequiredValidator(
                      errorText: "Enter College Code",
                    ).call,
                    controller: clgcodeController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "College Code"),
                  ),

                  SizedBox(height: 10),

                  TextFormField(
                    validator: RequiredValidator(
                      errorText: "Enter Username",
                    ).call,
                    controller: usernameController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Create Username"),
                  ),

                  SizedBox(height: 10),

                  TextFormField(
                    validator: RequiredValidator(
                      errorText: "Enter Password",
                    ).call,
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Create Password"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                createaction();
                Navigator.pop(context);
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog first
              _logout(); // then logout
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    //var box = Hive.box("users");
    //await box.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> fetchStaffs() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/account/STAFF/getall"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        staffs = data
            .map(
              (e) => {
                "name": e["name"].toString(),
                "dept": e["dept"].toString(),
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
    fetchStaffs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PRINCEPAL SCREEN"),
        foregroundColor: Colors.blueGrey,
        backgroundColor: Colors.amber,
        shadowColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await fetchStaffs();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Staff list refreshed")),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=4", // dummy image
                ),
              ),
              onPressed: () {
                _showProfileMenu(context);
              },
            ),
          ),
        ],
      ),

      body: staffs.isEmpty
          ? Center(child: Text("No Staff Added"))
          : ListView.builder(
              //physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: staffs.length,
              itemBuilder: (context, index) {
                final staff = staffs[index];

                return Card(
                  elevation: 6,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff["name"]!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text("Department: ${staff["dept"]}"),
                        Text("Username: ${staff["username"]}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}