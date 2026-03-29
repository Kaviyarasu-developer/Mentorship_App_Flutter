import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/models/community_model.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';
import 'package:practice_app/services/socket_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:practice_app/services/upload_service.dart' as UploadService;

class CommunityElementScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityElementScreen({super.key, required this.community});

  @override
  State<CommunityElementScreen> createState() => _CommunityElementScreenState();
}

class _CommunityElementScreenState extends State<CommunityElementScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<Map<String, dynamic>> messages = [];

  int messageCount = 0;

  late bool isMentor;
  bool isJoined = false;
  int membersCount = 0;
  bool isLoading = false;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    isMentor =
        SessionService.role == "MENTOR" &&
        (SessionService.userId == widget.community.mentorId);

    initData();
    loadMessages();

    SocketService.connect(
      communityId: widget.community.id,
      onMessage: (msg) {
        setState(() {
          final msgId = msg["id"];

          if (msgId != null) {
            if (!messages.any((m) => m["id"] == msgId)) {
              messages.add(msg);
            }
          } else {
            messages.add(msg);
          }
        });
      },
    );
  }

  Future<void> initData() async {
    final joined = await isJoinedFunc(
      widget.community.id,
      SessionService.userId,
    );

    setState(() {
      isJoined = joined;
      membersCount = widget.community.members;
    });
  }

  @override
  void dispose() {
    SocketService.disconnect();
    tabController.dispose();
    super.dispose();
  }

  Future<void> toggleJoin() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/toggle-join?communityId=${widget.community.id}&userId=${SessionService.userId}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          isJoined = !isJoined;

          widget.community.isjoined = isJoined;

          if (isJoined) {
            membersCount++;
          } else {
            membersCount--;
          }
        });
      }
    } catch (e) {
      debugPrint("join error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> isJoinedFunc(int communityId, int? userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/isJoined?communityId=$communityId&userId=$userId",
        ),
      );

      if (response.statusCode == 200) {
        return response.body == "true";
      }
    } catch (e) {
      debugPrint("isJoined error: $e");
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(int communityId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/community/$communityId/messages"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    return [];
  }

  Future<void> loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/${widget.community.id}/messages",
        ),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          messages = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Load error: $e");
    }
  }

  // --------------------- DELETTE MESSAGE -------------------------------------
  Future<void> deleteMessage(int messageId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          "${ApiConfig.baseUrl}/community/message/$messageId?userId=${SessionService.userId}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          messages.removeWhere((m) => m["id"] == messageId);
        });
      }
    } catch (e) {
      debugPrint("delete error: $e");
    }
  }

  // ---------------------  SEND MESSAGE ---------------------------------------
  void sendMessage({String? text, String? imageUrl}) async {
    if ((text == null || text.trim().isEmpty) && imageUrl == null) return;
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/community/message"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "communityId": widget.community.id,
          "userId": SessionService.userId,
          "message": text,
          "imageUrl": imageUrl,
          "username": SessionService.username,
          "role": SessionService.role,
        }),
      );
      if (response.statusCode == 200) {
        loadMessages();
        controller.clear();
      }
    } catch (e) {}

    /// SEND TO BACKEND
    //SocketService.sendMessage(msg);
  }

  // --------------------- CHAT UI  --------------------------------------------
  Widget buildMessages() {
    if (messages.isEmpty) {
      return Center(child: Text("No Posts or Messages"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final m = messages[index];
        bool isMe = m["userId"] == SessionService.userId;

        Color nameColor() {
          Color color;
          if (isMe) {
            color = const Color.fromARGB(195, 184, 0, 0);
          } else if (m["userId"] == widget.community.mentorId) {
            color = const Color.fromARGB(255, 3, 61, 1);
          } else {
            color = const Color.fromARGB(255, 95, 148, 26);
          }
          return color;
        }

        return Dismissible(
          key: ValueKey(m["id"] ?? index),

          direction: isMe ? DismissDirection.endToStart : DismissDirection.none,

          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Delete Message"),
                content: const Text(
                  "Are you sure you want to delete this message?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            );
          },

          onDismissed: (_) {
            if (m["id"] != null) {
              deleteMessage(m["id"]);
            }
          },

          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe ? Colors.indigo : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// USERNAME + ROLE
                  Text(
                    "${m["username"] ?? "user"} (${m["role"] ?? "USER"})",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: nameColor(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// MESSAGE
                  if (m["message"] != null &&
                      m["message"].toString().isNotEmpty)
                    Text(
                      m["message"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),

                  /// IMAGE
                  if (m["imageUrl"] != null &&
                      m["imageUrl"].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Image.network(
                        m["imageUrl"].toString().startsWith("http")
                            ? m["imageUrl"] // already full URL
                            : "${ApiConfig.baseUrl2}${m["imageUrl"]}", // backend path

                        height: 150,
                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 50);
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //----------------------------- INPUT BAR-------------------------------------
  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
      ),
      child: Row(
        children: [
          if (isMentor)
            IconButton(icon: const Icon(Icons.add), onPressed: openPostPanel),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Ask something...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          CircleAvatar(
            backgroundColor: Colors.indigo,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                sendMessage(text: controller.text);
                controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  //c-----------------------POST PANEL------------------------------------
  void openPostPanel() {
    final TextEditingController postController = TextEditingController();
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Post",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  /// TEXT
                  TextField(
                    controller: postController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write something...",
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// IMAGE PREVIEW
                  if (selectedImage != null)
                    Image.file(selectedImage!, height: 150),

                  /// PICK IMAGE
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text("Pick Image"),
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );

                      if (picked != null) {
                        setStateModal(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  /// POST BUTTON
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Image is required")),
                        );
                        return;
                      }

                      //STEP 1: UPLOAD IMAGE
                      String? url = await UploadService.uploadImage(
                        selectedImage!,
                      );

                      if (url != null) {
                        sendMessage(text: postController.text, imageUrl: url);
                      } else {
                        sendMessage(text: postController.text, imageUrl: url);
                      }

                      Navigator.pop(context);
                    },
                    child: const Text("Post"),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //--------------------------------- UI ---------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          /// HEADER
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            color: Colors.indigo,
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),

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
                // if (!isMentor)
                //   Positioned(
                //     bottom: 10,
                //     right: 10,
                //     child: ElevatedButton(
                //       onPressed: isLoading ? null : toggleJoin,
                //       child: Text(isJoined ? "Joined" : "Join"),
                //     ),
                //   ),
              ],
            ),
          ),

          /// TABS
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(icon: Icon(Icons.chat)),
              Tab(icon: Icon(Icons.post_add)),
            ],
          ),

          /// CONTENT
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                /// CHAT
                Column(
                  children: [
                    Expanded(child: buildMessages()),
                    buildInputBar(),
                  ],
                ),

                /// POSTS
                ListView(
                  children: messages
                      .where((m) => m["imageUrl"] != null)
                      .map(
                        (m) => ListTile(
                          title: Text(m["username"] ?? "user"),
                          subtitle: const Text("Posted image"),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
