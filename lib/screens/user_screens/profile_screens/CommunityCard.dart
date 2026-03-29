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
  late bool isJoined;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    isJoined = widget.community.isjoined;
    print(isJoined);
  }

  // ---------------- TOGGLE JOIN / LEAVE --------------------------------------
  Future<void> toggleJoin() async {
    try {
      final userId = SessionService.userId;

      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      setState(() {
        isLoading = true;
      });
      final url =
          "${ApiConfig.baseUrl}/community/toggle-join?userId=$userId&communityId=${widget.community.id}";
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          isJoined = !isJoined;
          widget.community.isjoined = isJoined;

          widget.community.members =
              (widget.community.members) + (isJoined ? 1 : -1);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Action failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Server error")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // -------------------  SAFE IMAGE BUILDER------------------------------------
  Widget buildBannerImage() {
    final url = widget.community.imageUrl ?? "";

    if (url.isEmpty || url == "null" || !url.startsWith("http")) {
      return Container(
        height: 180,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.groups, size: 50, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          color: Colors.grey[300],
          child: const Icon(Icons.groups, size: 50, color: Colors.grey),
        );
      },
    );
  }

  ImageProvider getProfileImage() {
    final url = widget.community.profileImage ?? "";

    if (url.isEmpty || url == "null" || !url.startsWith("http")) {
      return const AssetImage("assets/images/profile_placeholder_image.png");
    }

    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityElementScreen(community: widget.community),
          ),
        );

        if (result == true) {
          setState(() {});
        }
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: buildBannerImage(),
                ),

                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${widget.community.members} members",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(12),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 28, backgroundImage: getProfileImage()),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.community.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "@${widget.community.username ?? "unknown"}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          widget.community.field ?? "",
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  widget.isOwner
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {},
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: "edit", child: Text("Edit")),
                            PopupMenuItem(
                              value: "delete",
                              child: Text("Delete"),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isJoined
                                ? Colors.grey
                                : Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: isLoading ? null : toggleJoin,
                          child: isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isJoined ? "Joined" : "Join"),
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
