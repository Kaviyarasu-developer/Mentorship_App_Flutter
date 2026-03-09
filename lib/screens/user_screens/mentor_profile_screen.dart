import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/screens/user_screens/following_screen.dart';

class MentorProfileScreen extends StatefulWidget {
  final int id;
  final String name;
  final String username;
  final bool isOwner;
  final String role;

  const MentorProfileScreen({
    super.key,
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isOwner,
  });

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool isFollowing = false;

  final users = Hive.box("users");

  int get userId => users.get("id");

  String baseUrl = "http://10.0.2.2:8080/app";

  Future<void> followUser() async {
    await http.post(
      Uri.parse("$baseUrl/follow/${widget.id}?followerId=$userId"),
    );

    setState(() {
      isFollowing = true;
    });
  }

  Future<void> unfollowUser() async {
    await http.delete(
      Uri.parse("$baseUrl/follow/${widget.id}?followerId=$userId"),
    );

    setState(() {
      isFollowing = false;
    });
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),

          Text(
            widget.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text("@${widget.username}"),

          const SizedBox(height: 20),

          if (!widget.isOwner)
            ElevatedButton(
              onPressed: () {
                if (isFollowing) {
                  unfollowUser();
                } else {
                  followUser();
                }
              },

              child: Text(isFollowing ? "Following" : "Follow"),
            ),

          const Divider(),

          TabBar(
            controller: tabController,

            tabs: const [
              Tab(text: "Communities"),
              Tab(text: "Classes"),
              Tab(text: "Following"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,

              children: [
                const Center(child: Text("No Communities")),

                const Center(child: Text("No Classes")),

                FollowingScreen(userId: widget.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
