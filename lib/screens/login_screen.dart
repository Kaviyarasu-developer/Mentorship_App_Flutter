import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
//import 'package:http/http.dart' as http;
import 'package:practice_app/screens/admin_screens/adminpage_screen.dart';
import 'package:practice_app/screens/user_screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    try {
      // final response = await http.post(
      //   Uri.parse("http://10.0.2.2:8080/api/login"),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "email": emailController.text,
      //     "password": passwordController.text,
      //   }),
      // );

      if (true) {
        //code : response.statusCode == 200
        // Success → Navigate

        if (passwordController == "admin") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminpageScreen()),
          );
        }
      }
      // else {
      //   // Error → Show message
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
      // }
    } catch (e) {
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
  Widget build(BuildContext build) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50),

        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: emailController,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Enter UserName"),
                    EmailValidator(errorText: "Invalid Email"),
                  ]).call,

                  decoration: InputDecoration(
                    hintText: 'Email ID', // Placeholder text.
                    labelText: 'Email', // Label for the field.
                    prefixIcon: Icon(
                      Icons.email, // Email icon.
                    ),

                    errorStyle: TextStyle(
                      fontSize: 18.0,
                    ), // Error message styling.

                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(
                        Radius.circular(9.0),
                      ), // Rounded border.
                    ),
                  ),
                ),

                SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    labelText: 'password',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(9.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
                  child: Text('forget password'),
                ),

                Padding(
                  padding: EdgeInsets.all(20),

                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text("Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
