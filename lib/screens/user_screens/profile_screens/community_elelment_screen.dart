import 'package:flutter/material.dart';
import 'package:practice_app/models/community_model.dart';

class CommunityElementScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityElementScreen({super.key, required this.community});

  @override
  State<CommunityElementScreen> createState() => _CommunityElementScreenState();
}

class _CommunityElementScreenState extends State<CommunityElementScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool joined = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          /// HEADER IMAGE (1/4 SCREEN)
          Stack(
            children: [
              // Image.network(
              //   widget.community.imageUrl,
              //   height: MediaQuery.of(context).size.height * 0.25,
              //   width: double.infinity,
              //   fit: BoxFit.cover,
              // ),

              /// GRADIENT
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),

              /// BACK BUTTON
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              /// COMMUNITY NAME
              Positioned(
                bottom: 50,
                left: 16,
                child: Text(
                  widget.community.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// JOIN BUTTON
              Positioned(
                bottom: 4,
                right: 10,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      joined = !joined;
                    });
                  },
                  child: Text(joined ? "Joined" : "Join"),
                ),
              ),

              /// MEMBERS
              Positioned(
                bottom: 15,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${widget.community.members} members",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          /// TAB ICONS
          Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              indicatorColor: Colors.indigo,
              tabs: const [
                Tab(icon: Icon(Icons.feed)),

                Tab(icon: Icon(Icons.video_library)),
              ],
            ),
          ),

          /// TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                /// POSTS
                ListView(
                  children: const [
                    ListTile(title: Text("Community Post Example")),
                  ],
                ),

                /// NOTES / VIDEOS
                ListView(
                  children: const [
                    ListTile(title: Text("Notes and Videos Section")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
