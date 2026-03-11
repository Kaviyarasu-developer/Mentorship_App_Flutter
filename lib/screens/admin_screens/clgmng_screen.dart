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

  final clgnameController = TextEditingController();
  final principalnameController = TextEditingController();
  final codeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ---------------- FETCH COLLEGES ----------------

  Future<void> fetchColleges() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/app/account/PRINCIPAL/getall"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        colleges = data
            .map(
              (e) => {
                "name": e["clgname"].toString(),
                "code": e["clgcode"].toString(),
                "username": e["username"].toString(),
              },
            )
            .toList();
      });
      print(colleges);
    }
  }

  // ---------------- CREATE COLLEGE ----------------

  Future<void> createCollege() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/app/account/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "clgname": clgnameController.text.trim(),
          "name": principalnameController.text.trim(),
          "clgcode": int.parse(codeController.text),
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
          "role": "PRINCIPAL",
        }),
      );

      if (response.statusCode == 200) {
        await fetchColleges();

        clgnameController.clear();
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
                    controller: clgnameController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter college name" : null,
                    decoration: const InputDecoration(
                      labelText: "College Name",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: principalnameController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter Principal Name" : null,
                    decoration: const InputDecoration(
                      labelText: "Principal Name",
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
    clgnameController.dispose();
    principalnameController.dispose();
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
