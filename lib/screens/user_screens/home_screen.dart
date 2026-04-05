import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice_app/services/api_config.dart';
import 'package:practice_app/services/sessoin_service.dart';
import 'package:practice_app/services/socket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController questionController = TextEditingController();

  String get userName => SessionService.username ?? "";
  String get userRole => SessionService.role ?? "";
  int get userId => SessionService.userId ?? 0;

  List<Map<String, dynamic>> questions = [];

  bool loading = true;

  // ---------------- FETCH QUESTIONS ----------------

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/questions?userId=$userId"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          questions = data
              .map(
                (e) => {
                  "userId": e["userId"],
                  "id": e["id"],
                  "user": e["username"],
                  "role": e["role"],
                  "question": e["message"],
                  "likes": e["likesCount"],
                  "isLiked": e["isLiked"],
                  "replies": e["replyCount"],
                },
              )
              .toList();

          print(questions);

          loading = false;
        });
      }
    } catch (e) {
      debugPrint("fetch error: $e");
    }
  }

  // ---------------- SAVE QUESTION ----------------
  Future<void> saveQuestion() async {
    if (questionController.text.trim().isEmpty) return;

    String questionText = questionController.text.trim();

    questionController.clear();
    FocusScope.of(context).unfocus();

    SocketService.send(
      destination: "/app/question.create",
      body: {"message": questionText, "userId": userId},
    );
  }

  //-----------------  DELETE QUESTION  -----------------------

  Future<void> deleteQuestion(int questionId) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/questions/$questionId"),
      );

      if (response.statusCode == 200) {
        fetchQuestions();
      }
    } catch (e) {}
  }

  /// DELETE CONFIRMATION
  void showDeleteDialog(int questionId) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Question"),
          content: const Text("Are you sure you want to delete this Question?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                deleteQuestion(questionId);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // ----------------  TOGGLE LIKE QUESTION ----------------

  Future<void> likeQuestion(int questionId) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/questions/$questionId/like?userId=$userId",
        ),
      );

      if (response.statusCode == 200) {
        fetchQuestions();
      }
    } catch (e) {
      debugPrint("like error: $e");
    }
  }

  // ---------------- FETCH REPLIES ----------------

  Future<List<Map<String, dynamic>>> fetchReplies(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/replies/$questionId?userId=$userId"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map(
              (e) => {
                "id": e["id"] ?? 0,
                "userId": e["userId"] ?? 0,
                "user": e["username"],
                "role": e["role"],
                "message": e["message"],
                "isLiked": e["isLiked"] ?? false,
                "likes": e["likesCount"] ?? 0,
              },
            )
            .toList();
      }
    } catch (e) {
      debugPrint("reply fetch error: $e");
    }

    return [];
  }

  // ---------------- SEND REPLY ----------------
  void sendReply(int questionId, String message) {
    SocketService.send(
      destination: "/app/reply.create",
      body: {"message": message, "userId": userId, "questionId": questionId},
    );
  }

  //----------------- DELETE REPLY ----------------------

  Future<void> deleteReply(
    int replyId,
    int questionId,
    Function setStateModal,
    List replies,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/replies/$replyId"),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        // remove instantly (no reload)
        setStateModal(() {
          replies.removeWhere((r) => r["id"] == replyId);
        });
        fetchQuestions();
      }
    } catch (e) {
      debugPrint("delete reply error: $e");
    }
  }

  //----------------- LIKE REPLY ----------------------
  Future<void> likeReply(int replyId) async {
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/replies/$replyId/like?userId=$userId"),
      );
    } catch (e) {
      debugPrint("like reply error: $e");
    }
  }

  // ---------------- OPEN REPLY PANEL ----------------

  void openReplies(int questionId, Function refreshHome) async {
    List<Map<String, dynamic>> replies = await fetchReplies(questionId);

    TextEditingController replyController = TextEditingController();

    Function? setStateModalRef;

    SocketService.subscribe(
      destination: "/topic/replies/$questionId",
      onMessage: (data) {
        if (setStateModalRef == null) return;

        setStateModalRef!(() {
          if (data["type"] == "DELETE") {
            replies.removeWhere((r) => r["id"] == data["id"]);
            return;
          }

          final exists = replies.any((r) => r["id"] == data["id"]);

          if (!exists) {
            replies.add(data);
          }
        });
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            setStateModalRef = setStateModal;
            return FractionallySizedBox(
              heightFactor: 0.75,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// DRAG HANDLE
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Replies",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ///  CHAT STYLE LIST
                    Expanded(
                      child: replies.isEmpty
                          ? const Center(child: Text("No replies yet"))
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: replies.length,
                              itemBuilder: (context, index) {
                                final r = replies[index];
                                bool isMe = (r["userId"] ?? -1) == userId;

                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,

                                  child: Dismissible(
                                    key: ValueKey(r["id"]),

                                    direction: isMe
                                        ? DismissDirection.endToStart
                                        : DismissDirection.none,

                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      color: Colors.red,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),

                                    onDismissed: (_) {
                                      deleteReply(
                                        r["id"],
                                        questionId,
                                        setStateModal,
                                        replies,
                                      );
                                    },

                                    child: GestureDetector(
                                      onDoubleTap: () async {
                                        await likeReply(r["id"]);

                                        List<Map<String, dynamic>>
                                        updatedReplies = await fetchReplies(
                                          questionId,
                                        );

                                        setStateModal(() {
                                          replies = updatedReplies;
                                        });
                                      },

                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.all(12),

                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.7,
                                        ),

                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.indigo
                                              : Colors.grey[200],

                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: Radius.circular(
                                              isMe ? 16 : 0,
                                            ),
                                            bottomRight: Radius.circular(
                                              isMe ? 0 : 16,
                                            ),
                                          ),
                                        ),

                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// NAME + ROLE
                                            Text(
                                              isMe
                                                  ? "You (${SessionService.role})"
                                                  : "${r["user"]} (${r["role"] ?? "USER"})",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isMe
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            /// MESSAGE
                                            Text(
                                              r["message"],
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  (r["isLiked"] ?? false)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),

                                                const SizedBox(width: 4),

                                                Text(
                                                  "${r["likes"] ?? 0}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isMe
                                                        ? Colors.white70
                                                        : Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(blurRadius: 5, color: Colors.black12),
                        ],
                      ),

                      child: Row(
                        children: [
                          /// TEXT FIELD
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              decoration: InputDecoration(
                                hintText: "Write a reply...",
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          /// SEND BUTTON
                          CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: () async {
                                if (replyController.text.trim().isEmpty) return;

                                sendReply(questionId, replyController.text);

                                replyController.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- INIT ----------------

  @override
  void initState() {
    super.initState();

    fetchQuestions();

    SocketService.connect(() {
      SocketService.subscribe(
        destination: "/topic/questions",
        onMessage: (data) {
          setState(() {
            // DELETE EVENT
            if (data["type"] == "DELETE") {
              questions.removeWhere((q) => q["id"] == data["id"]);
              return;
            }

            final exists = questions.any((q) => q["id"] == data["id"]);

            if (!exists) {
              questions.insert(0, {
                "userId": data["userId"],
                "id": data["id"],
                "user": data["username"],
                "role": data["role"],
                "question": data["message"],
                "likes": data["likesCount"],
                "isLiked": data["isLiked"],
                "replies": data["replyCount"],
              });
            }
          });
        },
      );
    });
  }

  @override
  void dispose() {
    SocketService.unsubscribe("/topic/questions");
    questionController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
          ? const Center(child: Text("No Questions Yet"))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),

              itemCount: questions.length,

              itemBuilder: (context, index) {
                final q = questions[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    q["user"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),

                                    child: Text(
                                      q["role"] ?? "",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    q["isLiked"]
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    likeQuestion(q["id"]);
                                  },
                                ),

                                Text("${q["likes"] ?? 0}"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          q["question"] ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                openReplies(q["id"], fetchQuestions);
                              },

                              icon: const Icon(Icons.chat_bubble_outline),

                              label: Text("${q["replies"] ?? 0} Replies"),
                            ),

                            const SizedBox(width: 10),

                            TextButton.icon(
                              onPressed: () {},

                              icon: const Icon(Icons.flag_outlined),

                              label: const Text("Report"),
                            ),

                            const SizedBox(width: 75),

                            /// THREE DOT MENU
                            if (q["userId"] == userId)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == "delete") {
                                    showDeleteDialog(q["id"]);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: "delete",
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 10),
                                        Text("Delete Question"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

        color: Colors.white,

        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: questionController,

                onSubmitted: (_) => saveQuestion(),

                decoration: InputDecoration(
                  hintText: "Ask a question...",

                  filled: true,
                  fillColor: Colors.grey[200],

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),

                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            const SizedBox(width: 8),

            CircleAvatar(
              backgroundColor: Colors.indigo,

              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),

                onPressed: saveQuestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
