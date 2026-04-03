import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:practice_app/models/community_model.dart';
import 'package:practice_app/screens/user_screens/profile_screens/CommunityCard.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<CommunityModel> allCommunities = [];
  bool isLoading = true;
  String selectedFilter = "ALL";

  @override
  void initState() {
    super.initState();
    fetchAllCommunities();
  }

  // ---------------- FETCH ----------------
  Future<void> fetchAllCommunities() async {
    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(
            "${ApiConfig.baseUrl}/community/all?userId=${SessionService.userId}",
          ),
        ),
        http.get(
          Uri.parse(
            "${ApiConfig.baseUrl}/community/joined?userId=${SessionService.userId}",
          ),
        ),
      ]);

      final allData = jsonDecode(responses[0].body);
      final joinedData = jsonDecode(responses[1].body);

      final joinedIds = joinedData.map((e) => e['id']).toSet();

      setState(() {
        allCommunities = List<CommunityModel>.from(
          allData.map((e) {
            final model = CommunityModel.fromJson(e);
            model.isjoined = joinedIds.contains(e['id']); // 🔥 key
            return model;
          }),
        );

        isLoading = false;
      });
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  List<CommunityModel> get currentList {
    if (selectedFilter == "Joined") {
      return allCommunities.where((c) => c.isjoined == true).toList();
    }
    return allCommunities;
  }

  // ---------------- DELETE ----------------
  void handleDelete(int id) {
    setState(() {
      allCommunities.removeWhere((c) => c.id == id);
    });
  }

  // ---------------- JOIN TOGGLE ----------------
  void handleJoinToggle(int id, bool isJoined) {
    setState(() {
      final community = allCommunities.firstWhere((c) => c.id == id);

      community.isjoined = isJoined;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = currentList;

    return Column(
      children: [
        // 🔥 STEP 4 → FILTER UI (PLACE HERE)
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text("ALL"),
              selected: selectedFilter == "ALL",
              onSelected: (_) {
                setState(() => selectedFilter = "ALL");
              },
            ),
            FilterChip(
              label: const Text("Joined"),
              selected: selectedFilter == "Joined",
              onSelected: (_) {
                setState(() => selectedFilter = "Joined");
              },
            ),
          ],
        ),

        // 🔥 STEP 5 → LIST (PLACE HERE)
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text("No Communities"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return CommunityCard(
                      key: ValueKey(list[index].id),
                      community: list[index],
                      isOwner: SessionService.userId == list[index].mentorId,
                      onDelete: handleDelete,
                      onJoinToggle: handleJoinToggle,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
