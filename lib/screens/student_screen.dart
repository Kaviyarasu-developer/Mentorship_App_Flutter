import 'package:flutter/material.dart';
import '../services/student_service.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<List<dynamic>> students;

  @override
  void initState() {
    super.initState();
    students = StudentService.fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students")),
      body: FutureBuilder<List<dynamic>>(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(snapshot.data![index]));
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
