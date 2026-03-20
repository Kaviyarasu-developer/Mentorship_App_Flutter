import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FollowingScreen extends StatefulWidget {
  final int userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<Map<String, dynamic>> following = [];

  bool loading = true;

  final String baseUrl = "http://10.0.2.2:8080/app";

  Future<void> fetchFollowing() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/follow/following/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          following = data
              .map(
                (e) => {
                  "id": e["id"],
                  "name": e["name"],
                  "username": e["username"],
                  "role": e["role"],
                },
              )
              .toList();

          loading = false;
        });
      }
    } catch (e) {
      debugPrint("following error $e");
    }
  }

  Future<void> unfollowUser(int followingId) async {
    try {
      await http.delete(
        Uri.parse("$baseUrl/follow/$followingId?followerId=${widget.userId}"),
      );

      fetchFollowing();
    } catch (e) {
      debugPrint("unfollow error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFollowing();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (following.isEmpty) {
      return const Center(child: Text("No Followings"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),

      itemCount: following.length,

      itemBuilder: (context, index) {
        final user = following[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Text(user["name"][0])),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    Text(
                      "@${user["username"]}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),

                onPressed: () {
                  unfollowUser(user["id"]);
                },

                child: const Text("Unfollow"),
              ),
            ],
          ),
        );
      },
    );
  }
}
