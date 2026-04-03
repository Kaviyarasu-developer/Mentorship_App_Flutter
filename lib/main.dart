import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:practice_app/models/user_model.dart';
import 'package:practice_app/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter()); 
  await Hive.openBox<UserModel>("users");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
