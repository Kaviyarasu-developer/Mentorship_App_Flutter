import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:practice_app/models/announcements_model.dart';
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';
import 'package:practice_app/services/socket_service.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  List<AnnouncementModel> announcements = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    fetchAnnouncements();

    SocketService.connect(() {
      SocketService.subscribe(
        destination: "/topic/announcements",
        onMessage: (data) {
          setState(() {
            if (data["type"] == "DELETE") {
              announcements.removeWhere((a) => a.id == data["id"]);
              return;
            }

            final newItem = AnnouncementModel.fromJson(data);

            final exists = announcements.any((a) => a.id == newItem.id);

            if (!exists) {
              announcements.insert(0, newItem);
            }
          });
        },
      );
    });
  }

    // ---------------- DISPOSE ----------------
@override
void dispose() {
  SocketService.unsubscribe("/topic/announcements");
  super.dispose();
}

  // ---------------- FETCH ----------------
  Future<void> fetchAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/announcements"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          announcements = data
              .map((e) => AnnouncementModel.fromJson(e))
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("fetch error: $e");
    }
  }

  // ---------------- DELETE ----------------
  Future<void> deletePost(int id) async {
    await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}/announcements/$id?userId=${SessionService.userId}",
      ),
    );

    fetchAnnouncements();
  }

  // ---------------- CREATE PANEL ----------------
  void openCreatePanel() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Announcement",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),

                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: "Content"),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );

                      if (picked != null) {
                        selectedImage = File(picked.path);
                        setStateModal(() {});
                      }
                    },
                    child: const Text("Pick Image"),
                  ),

                  const SizedBox(height: 10),

                  if (selectedImage != null)
                    Image.file(selectedImage!, height: 100),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      var request = http.MultipartRequest(
                        'POST',
                        Uri.parse("${ApiConfig.baseUrl}/announcements/create"),
                      );

                      request.fields["title"] = titleController.text;
                      request.fields["content"] = contentController.text;
                      request.fields["adminId"] = SessionService.userId
                          .toString();

                      if (selectedImage != null) {
                        request.files.add(
                          await http.MultipartFile.fromPath(
                            "file",
                            selectedImage!.path,
                          ),
                        );
                      }

                      await request.send();

                      Navigator.pop(context);

                      fetchAnnouncements();
                    },
                    child: const Text("Post"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],

      floatingActionButton: SessionService.role == "ADMIN"
          ? FloatingActionButton(
              onPressed: openCreatePanel,
              child: const Icon(Icons.add),
            )
          : null,

      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final a = announcements[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.indigo,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.adminName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              a.createdAt,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (SessionService.role == "ADMIN")
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => deletePost(a.id),
                        ),
                    ],
                  ),
                ),

                /// IMAGE
                if (a.imageUrl != null)
                  Image.network(
                    "${ApiConfig.baseUrl2}${a.imageUrl}",
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),

                /// CONTENT
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(a.content, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
