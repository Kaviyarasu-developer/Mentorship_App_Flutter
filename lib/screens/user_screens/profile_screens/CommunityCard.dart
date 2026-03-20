import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/models/community_model.dart';
import 'package:practice_app/screens/user_screens/profile_screens/community_elelment_screen.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';

class CommunityCard extends StatefulWidget {
  final CommunityModel community;
  final bool isOwner;

  const CommunityCard({
    super.key,
    required this.community,
    required this.isOwner,
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  bool isJoined = false;

  //--------------- JOIN COMMUNITY ----------------------------------------------
  Future<void> joinCommunity(BuildContext context) async {
    try {
      final studentId = SessionService.userId; // 🔥 get logged-in user

      if (studentId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/${widget.community.id}/join?studentId=$studentId",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          isJoined = true; // 🔥 UI updates
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Joined successfully")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to join")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Server error")));
    }
  }

  /// DELETE COMMUNITY
  Future<void> deleteCommunity(BuildContext context) async {
    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/community/delete/${widget.community.id}"),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Community deleted")));
    }
  }

  /// DELETE CONFIRMATION
  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Community"),
          content: const Text(
            "Are you sure you want to delete this community?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                deleteCommunity(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityElementScreen(community: widget.community),
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
                    widget.community.imageUrl,
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
                      "${widget.community.members} members",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                /// EDIT BUTTON (MENTOR ONLY)
                if (widget.isOwner)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {},
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
                    backgroundImage: NetworkImage(
                      widget.community.profileImage,
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// NAME + USERNAME
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.community.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        Text(
                          "@${widget.community.username}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  /// THREE DOT MENU (MENTOR)
                  if (widget.isOwner)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "delete") {
                          showDeleteDialog(context);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Delete Community"),
                            ],
                          ),
                        ),
                      ],
                    ),

                  /// JOIN BUTTON (USERS)
                  if (!widget.isOwner)
                    ElevatedButton(
                      onPressed: isJoined
                          ? null
                          : () async {
                              joinCommunity(context);
                              setState(() {
                                isJoined = true;
                              });
                            },
                      child: Text(isJoined ? "Joined" : "Join"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
