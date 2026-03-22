import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/models/community_model.dart';
import 'package:practice_app/screens/user_screens/profile_screens/CommunityCard.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';

class CommunityTab extends StatefulWidget {
  final bool isOwner;
  final int mentorId;

  const CommunityTab({
    super.key,
    required this.isOwner,
    required this.mentorId,
  });

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  List<CommunityModel> communities = [];

  bool isLoading = true;

  /// FETCH COMMUNITIES FROM BACKEND
  Future<void> fetchCommunities() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/mentor?mentorId=${widget.mentorId}&userId=${SessionService.userId}",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          communities = data.map((e) => CommunityModel.fromJson(e)).toList();
          isLoading = false;
        });
        print(communities[0].isjoined);
      }
    } catch (e) {
      print("community fetch error: $e");
    }
  }

  void openCreateCommunityPanel(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    String visibility = "Public";
    String field = "Programming";

    Future<void> createCommunity(
      BuildContext context,
      String name,
      String description,
      String visibility,
      String field,
      int mentorId,
    ) async {
      try {
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/community/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "communityName": name,
            "communityDesc": description,
            "communityImage": "",
            "communityField": field,
            "mentorId": mentorId,
          }),
        );

        if (response.statusCode == 200) {
          fetchCommunities();
          Navigator.pop(context);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Community Created")));
        }
      } catch (e) {
        print("create community error: $e");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        bool isCreating = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Community",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Community Name",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: "Public", child: Text("Public")),
                      DropdownMenuItem(
                        value: "College Only",
                        child: Text("College Only"),
                      ),
                    ],
                    onChanged: (v) {
                      visibility = v!;
                    },
                    decoration: const InputDecoration(labelText: "Visibility"),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(
                        value: "Programming",
                        child: Text("Programming"),
                      ),
                      DropdownMenuItem(value: "AI", child: Text("AI")),
                    ],
                    onChanged: (v) {
                      field = v!;
                    },
                    decoration: const InputDecoration(labelText: "Field"),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isCreating
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Enter community name"),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              isCreating = true;
                            });

                            await createCommunity(
                              context,
                              nameController.text,
                              descController.text,
                              visibility,
                              field,
                              widget.mentorId,
                            );

                            setState(() {
                              isCreating = false;
                            });
                          },

                    child: isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Create Community"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCommunities();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    /// 🔥 EMPTY STATE
    if (communities.isEmpty) {
      return Column(
        children: [
          /// ADD BUTTON (ONLY OWNER)
          if (widget.isOwner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  openCreateCommunityPanel(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Add Community",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Spacer(),

          const Center(
            child: Text(
              "No Communities",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),

          const Spacer(),
        ],
      );
    }

    /// 🔥 NORMAL LIST
    return Column(
      children: [
        /// ADD BUTTON (TOP)
        if (widget.isOwner)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                openCreateCommunityPanel(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    "Add Community",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        /// COMMUNITY LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              return CommunityCard(
                community: communities[index],
                isOwner: widget.isOwner,
              );
            },
          ),
        ),
      ],
    );
  }
}
