import 'package:flutter/material.dart';

class PeopleSearchScreen extends StatefulWidget {
  const PeopleSearchScreen({super.key});

  @override
  State<PeopleSearchScreen> createState() => _PeopleSearchScreen();
}

class _PeopleSearchScreen extends State<PeopleSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 2);
    // ListView(
    //   children: [Text("what")],

    // children: [
    //   Text("vendor"),
    //   SearchBar(),
    //   ListView(
    //     children: [
    //       Card(child: Text("student")),
    //       Card.filled(),
    //     ],
    //   ),
    // ],
    //);
  }
}
