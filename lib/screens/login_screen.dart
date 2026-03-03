import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/screens/admin_screens/adminpage_screen.dart';
import 'package:practice_app/screens/principal_screens/princepal_main_screen.dart';
import 'package:practice_app/screens/user_screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/app/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": emailController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final box = Hive.box("users");

        // Store values
        await box.put("role", data["role"]);
        await box.put("username", data["username"]);

        // Read stored value
        String? role = box.get("role");

        print("Stored role: $role");
        if (role == "ADMIN") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminpageScreen()),
          );
        } else if (role == "PRINCEPAL") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PrincepalMainScreen()),
          );
        } else if (role == "STAFF" || role == "STD" || role == "MENTOR") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      } else {
        // Error → Show message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e, stack) {
      print("ERROR: $e");
      print("STACK: $stack");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Server error")));
    }
  }

  void _submit() {
    if (_formkey.currentState!.validate()) {
      login(); // Only call backend if form is valid
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth > 600 ? 450 : 350, // Responsive
              ),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔥 Logo
                        Column(
                          children: [
                            Icon(Icons.school, size: 70, color: Colors.indigo),
                            SizedBox(height: 10),
                            Text(
                              "Student Mentorship",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // 📧 Email Field
                        TextFormField(
                          controller: emailController,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Enter Email"),
                            EmailValidator(errorText: "Invalid Email"),
                          ]).call,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // 🔐 Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          validator: RequiredValidator(
                            errorText: "Enter Password",
                          ).call,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: 25),

                        // 🔥 Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
