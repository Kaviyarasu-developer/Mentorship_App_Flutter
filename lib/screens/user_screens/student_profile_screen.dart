import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/screens/user_screens/following_screen.dart';
import 'package:practice_app/services/api_config.dart';

class StudentProfileScreen extends StatefulWidget {
  final int id;
  final String name;
  final String username;
  final bool isOwner;
  final String role;

  const StudentProfileScreen({
    super.key,
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isOwner,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  int followersCount = 0;

  bool isFollowing = false;

  bool showAbout = false;

  String aboutText =
      "This mentor helps students with coding, projects and career guidance.";

  final users = Hive.box("users");

  int get userId => users.get("id");

  Future<void> followUser() async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/follow/${widget.id}?followerId=$userId"),
    );

    if (response.statusCode == 200) {
      setState(() {
        isFollowing = true;
      });
    }
  }

  Future<void> unfollowUser() async {
    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/follow/${widget.id}?followerId=$userId"),
    );
    if (response.statusCode == 200) {
      setState(() {
        isFollowing = false;
      });
    }
  }

  Future<void> isFollowingUser() async {
    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/follow/isFollowing?followerId=$userId&followingId=${widget.id}",
      ),
    );
    if (response.statusCode == 200) {
      setState(() {
        isFollowing = bool.parse(response.body);
      });
    }
  }

  Future<void> countFollowers() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/follow/followers/${widget.id}"),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      data
          .map(
            (e) => {
              "user": e["username"],
              "role": e["role"],
              "message": e["message"],
            },
          )
          .toList();
      followersCount = data.length;
    }
  }

  @override
  void initState() {
    super.initState();
    isFollowingUser();
    countFollowers();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                /// PROFILE ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// AVATAR
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                    ),

                    const SizedBox(width: 16),

                    /// NAME + USERNAME + FOLLOWERS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "@${widget.username}",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Text("$followersCount Followers"),
                              SizedBox(width: 20),
                              Text("0 Ratings"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// FOLLOW BUTTON
                if (!widget.isOwner)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (isFollowing) {
                          countFollowers();
                          unfollowUser();
                        } else {
                          countFollowers();
                          followUser();
                        }
                      },
                      child: Text(
                        isFollowing ? "FOLLOWING" : "FOLLOW",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                /// ABOUT TITLE
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAbout = !showAbout;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "About the Mentor",
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),

                /// ABOUT TEXT
                if (showAbout)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      aboutText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: "Communities"),
              Tab(text: "Following"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                const Center(child: Text("No Communities")),

                FollowingScreen(userId: widget.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
