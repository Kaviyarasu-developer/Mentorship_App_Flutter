import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/screens/admin_screens/admin_main_screen.dart';
import 'package:practice_app/screens/principal_screens/princepal_main_screen.dart';
import 'package:practice_app/screens/user_screens/main_screen.dart';
import 'package:practice_app/services/sessoin_service.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formkey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool isLoading = false;

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

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> login() async {
  setState(() {
    isLoading = true;
  });

  try {
    final data = await AuthService.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    if (data != null) {
      final user = UserModel.fromJson(data);

      // ✅ SAVE USING SESSION SERVICE
      await SessionService.saveUser(user);

      // ✅ NAVIGATION BASED ON ROLE
      if (user.role == "ADMIN") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminpageScreen()),
        );
      } else if (user.role == "PRINCIPAL") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PrincepalMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Server connection error")),
    );
  }

  setState(() {
    isLoading = false;
  });
}

  void _submit() {
    if (_formkey.currentState!.validate()) {
      login();
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
                maxWidth: screenWidth > 600 ? 450 : 350,
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

                        SizedBox(height: 30),

                        TextFormField(
                          controller: usernameController,
                          validator: RequiredValidator(
                            errorText: "Enter Username",
                          ).call,
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

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

                        SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
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
