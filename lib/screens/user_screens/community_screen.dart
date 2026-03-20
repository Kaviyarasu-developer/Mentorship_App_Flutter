import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/models/community_model.dart';
import 'package:practice_app/screens/user_screens/profile_screens/community_elelment_screen.dart';
import 'package:practice_app/services/api_config.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreen();
}

class _CommunityScreen extends State<CommunityScreen> {
  List<CommunityModel> communities = [];

  bool isLoading = true;

  /// FETCH COMMUNITIES FROM BACKEND
  Future<void> fetchCommunities() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/community/all"),
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        final List data = jsonDecode(response.body);

        setState(() {
          communities = data.map((e) => CommunityModel.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("community fetch error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCommunities();
  }

  @override
  Widget build(BuildContext build) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        /// COMMUNITY LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              return CommunityCard(
                community: communities[index],
                isOwner: false,
              );
            },
          ),
        ),
      ],
    );
  }
}

class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final bool isOwner;

  const CommunityCard({
    super.key,
    required this.community,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityElementScreen(community: community),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE BANNER
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    community.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                /// MEMBERS COUNT
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${community.members} members",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            /// COMMUNITY INFO
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  /// PROFILE IMAGE
                  CircleAvatar(
                    backgroundImage: NetworkImage(community.profileImage),
                  ),

                  const SizedBox(width: 10),

                  /// NAME + USERNAME
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        Text(
                          "@${community.username}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  /// JOIN BUTTON (USERS)
                  if (!isOwner)
                    ElevatedButton(onPressed: () {}, child: const Text("Join")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
