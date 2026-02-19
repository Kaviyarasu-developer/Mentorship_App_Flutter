import 'package:flutter/material.dart';

class ClgmngScreen extends StatefulWidget {
  const ClgmngScreen({super.key});

  @override
  State<ClgmngScreen> createState() => _ClgmngScreenState();
}

class _ClgmngScreenState extends State<ClgmngScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      
      children: [
        Card(child: Text("SEC")),
        Card(child: Text("Mountzion")),
      ],
    );
  }
}
