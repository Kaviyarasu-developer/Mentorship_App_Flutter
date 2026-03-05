import 'package:flutter/material.dart';

class MentorProfileScreen extends StatefulWidget {
  final String name;
  final String username;

  const MentorProfileScreen({
    super.key,
    required this.name,
    required this.username,
  });

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen>
    with SingleTickerProviderStateMixin {
  bool showAbout = false;
  bool isFollowing = false;

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          /// ---------------- HEADER ----------------
          Stack(
            clipBehavior: Clip.none,
            children: [
              /// Banner
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
              ),

              /// Back Button
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              /// Profile Image
              Positioned(
                bottom: -50,
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          /// ---------------- NAME ----------------
          Text(
            widget.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          /// USERNAME
          Text(
            "@${widget.username}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          /// ---------------- FOLLOWERS + RATINGS ----------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("0 Followers"),
              SizedBox(width: 25),
              Text("0 Ratings"),
            ],
          ),

          const SizedBox(height: 12),

          /// ---------------- ABOUT SECTION ----------------
          GestureDetector(
            onTap: () {
              setState(() {
                showAbout = !showAbout;
              });
            },
            child: Column(
              children: [
                Row(
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

                if (showAbout)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "This mentor helps students with coding, projects and career guidance.",
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// ---------------- FOLLOW BUTTON ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                ),
                onPressed: () {
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                },
                child: Text(isFollowing ? "FOLLOWING" : "FOLLOW"),
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Divider(),

          /// ---------------- TABS ----------------
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: "Communities"),
              Tab(text: "Posts"),
            ],
          ),

          /// ---------------- TAB CONTENT ----------------
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                Center(child: Text("No Communities")),
                Center(child: Text("No Posts")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
