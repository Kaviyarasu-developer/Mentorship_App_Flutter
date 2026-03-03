import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClgmngScreen extends StatefulWidget {
  const ClgmngScreen({super.key});

  @override
  State<ClgmngScreen> createState() => _ClgmngScreenState();
}

class _ClgmngScreenState extends State<ClgmngScreen> {
  // 🔥 Local college list (temporary storage)
  List<Map<String, String>> colleges = [];
  final _formkey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> fetchColleges() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/app/college/getall"),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final List data = jsonDecode(response.body);

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

  void _showAddCollegeDialog() {
    Future<void> create() async {
      try {
        final response = await http.post(
          Uri.parse("http://10.0.2.2:8080/app/college/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "clgname": nameController.text,
            "clgcode": int.parse(codeController.text),
            "username": usernameController.text,
            "clgpassword": passwordController.text,
          }),
        );
        if (response.statusCode == 200) {
          await fetchColleges(); // refresh list
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Server error")));
      }
    }

    void createaction() {
      if (_formkey.currentState!.validate()) {
        create();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add College"),
          content: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "College Name"),
                  ),

                  SizedBox(height: 10),

                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(labelText: "College Code"),
                  ),

                  SizedBox(height: 10),

                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: "Username"),
                  ),

                  SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
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

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("College Management"),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddCollegeDialog),
        ],
      ),

      body: colleges.isEmpty
          ? Center(child: Text("No Colleges Added"))
          : ListView.builder(
              //physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: colleges.length,
              itemBuilder: (context, index) {
                final college = colleges[index];

                return Card(
                  elevation: 6,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college["name"]!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
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
