import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClgmngScreen extends StatefulWidget {
  const ClgmngScreen({super.key});

  @override
  State<ClgmngScreen> createState() => _ClgmngScreenState();
}

class _ClgmngScreenState extends State<ClgmngScreen> {
  List<Map<String, String>> colleges = [];

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ---------------- FETCH COLLEGES ----------------

  Future<void> fetchColleges() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/app/college/getall"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        colleges = data
            .map(
              (e) => {
                "name": e["clgName"].toString(),
                "code": e["clgCode"].toString(),
                "username": e["username"].toString(),
              },
            )
            .toList();
      });
    }
  }

  // ---------------- CREATE COLLEGE ----------------

  Future<void> createCollege() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/app/college/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "code": int.parse(codeController.text),
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        await fetchColleges();

        nameController.clear();
        codeController.clear();
        usernameController.clear();
        passwordController.clear();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Server error")));
    }
  }

  // ---------------- ADD COLLEGE DIALOG ----------------

  void _showAddCollegeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add College"),

          content: SingleChildScrollView(
            child: Form(
              key: _formKey,

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  TextFormField(
                    controller: nameController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter college name" : null,
                    decoration: const InputDecoration(
                      labelText: "College Name",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter college code" : null,
                    decoration: const InputDecoration(
                      labelText: "College Code",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: usernameController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter username" : null,
                    decoration: const InputDecoration(labelText: "Username"),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter password" : null,
                    decoration: const InputDecoration(labelText: "Password"),
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
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await createCollege();

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

  // ---------------- INIT ----------------

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  // ---------------- DISPOSE ----------------

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("College Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCollegeDialog,
          ),
        ],
      ),

      body: colleges.isEmpty
          ? const Center(child: Text("No Colleges Added"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: colleges.length,

              itemBuilder: (context, index) {
                final college = colleges[index];

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 16),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          college["name"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text("Code: ${college["code"]}"),

                        Text("Username: ${college["username"]}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
