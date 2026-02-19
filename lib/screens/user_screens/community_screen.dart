import 'package:flutter/widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreen();
}

class _CommunityScreen extends State<CommunityScreen> {
  @override
  Widget build(BuildContext build) {
    return Padding(padding: EdgeInsets.all(20), child: Text("Community Tab"));
  }
}
