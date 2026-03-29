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
  State<CommunityScreen> createState() => _CommunityScreen();
}

class _CommunityScreen extends State<CommunityScreen> {
  String selectedFilter = "ALL";
  List<CommunityModel> allCommunities = [];
  List<CommunityModel> joinedCommunities = [];

  bool isLoading = true;

  /// FETCH COMMUNITIES FROM BACKEND
  Future<void> fetchCommunities() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/all?userId=${SessionService.userId}",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          allCommunities = data.map((e) => CommunityModel.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("community fetch error: $e");
    }
  }

  Future<void> fetchJoinedCommunites() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/joined?userId=${SessionService.userId}",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          joinedCommunities = data
              .map((e) => CommunityModel.fromJson(e))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {}
  }

  // -------------------------------- FILTERED LIST ----------------------------
  List<CommunityModel> get currentList {
    return selectedFilter == "Joined" ? joinedCommunities : allCommunities;
  }

  // ------------------------ FILTER BAR ---------------------------------------
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Wrap(
        spacing: 8,

        children: [_buildFilterChip("ALL"), _buildFilterChip("Joined")],
      ),
    );
  }

  // ------------------------- FILTER CHIP -------------------------------------
  Widget _buildFilterChip(String role) {
    return FilterChip(
      label: Text(role),

      selected: selectedFilter == role,

      onSelected: (_) async {
        setState(() {
          selectedFilter = role;
          isLoading = true;
        });

        if (role == "Joined") {
          await fetchJoinedCommunites();
        } else {
          await fetchCommunities();
        }

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      },
    );
  }

  // -------------------------------- LOAD ALL ---------------------------------
  Future<void> fetchAllCommunities() async {
    await Future.wait([fetchCommunities(), fetchJoinedCommunites()]);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllCommunities();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = currentList; // ✅ use local variable

    return Column(
      children: [
        _buildFilterBar(),

        Expanded(
          child: list.isEmpty
              ? const Center(child: Text("No Communities"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return CommunityCard(
                      community: list[index],
                      isOwner: SessionService.userId == list[index].mentorId,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
