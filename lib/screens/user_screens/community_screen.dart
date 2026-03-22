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
  List<CommunityModel> communities = [];

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
