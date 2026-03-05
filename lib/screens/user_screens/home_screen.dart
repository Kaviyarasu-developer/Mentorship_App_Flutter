import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController questionController = TextEditingController();

  final users = Hive.box("users");

  String get userName => users.get("username");
  String get userRole => users.get("role");
  int get userId => users.get("id");

  final String baseUrl = "http://10.0.2.2:8080";

  List<Map<String, dynamic>> questions = [];

  /// GET QUESTIONS FROM BACKEND
  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/questions"));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          questions = data
              .map(
                (e) => {
                  "id": e["id"],
                  "user": e["username"],
                  "role": e["role"],
                  "question": e["message"],
                  "likes": e["likesCount"],
                  "replies": e["replyCount"],
                },
              )
              .toList();
        });
      }
    } catch (e) {
      print("fetch error: $e");
    }
  }

  /// SAVE QUESTION
  Future<void> saveQuestion() async {
    if (questionController.text.trim().isEmpty) return;

    String questionText = questionController.text;

    /// show immediately in UI
    setState(() {
      questions.insert(0, {
        "id": -1,
        "user": userName,
        "role": userRole,
        "question": questionText,
        "likes": 0,
        "replies": 0,
      });
    });

    questionController.clear();

    FocusScope.of(context).unfocus();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/questions"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"message": questionText, "userId": userId}),
      );

      if (response.statusCode == 200) {
        fetchQuestions();
      }
    } catch (e) {
      print("save error: $e");
    }
  }

  /// LIKE QUESTION
  Future<void> likeQuestion(int questionId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/questions/$questionId/like?userId=$userId"),
      );

      if (response.statusCode == 200) {
        fetchQuestions();
      }
    } catch (e) {
      print("like error: $e");
    }
  }

  ///------------------- GET REPLIES FROM BACKEND-------------------------------
  Future<List<Map<String, dynamic>>> fetchReplies(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/questions/$questionId/replies"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map(
              (e) => {
                "user": e["username"],
                "role": e["role"],
                "message": e["message"],
              },
            )
            .toList();
      }
    } catch (e) {
      print("reply fetch error: $e");
    }

    return [];
  }

  ///-----------------SAVE REPLY------------------------------------------------
  Future<void> sendReply(int questionId, String message) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/questions/$questionId/reply"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message, "userId": userId}),
      );

      fetchQuestions();
    } catch (e) {
      print("reply send error: $e");
    }
  }

  ///--------------------REPLY PANEL--------------------------------------------
  void openReplies(int questionId) async {
    List<Map<String, dynamic>> replies = await fetchReplies(questionId);

    TextEditingController replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: 500,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      "Replies",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// REPLIES LIST
                    Expanded(
                      child: replies.isEmpty
                          ? const Center(child: Text("No replies yet"))
                          : ListView.builder(
                              itemCount: replies.length,
                              itemBuilder: (context, index) {
                                final r = replies[index];

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        r["user"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          r["role"],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(r["message"]),
                                );
                              },
                            ),
                    ),

                    /// REPLY INPUT
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: replyController,
                            decoration: const InputDecoration(
                              hintText: "Write a reply...",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (replyController.text.trim().isEmpty) return;

                            await sendReply(questionId, replyController.text);

                            replies.add({
                              "user": userName,
                              "role": userRole,
                              "message": replyController.text,
                            });

                            replyController.clear();
                            setStateModal(() {});
                          },
                        ),
                      ],
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

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: questions.isEmpty
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
                        /// TOP ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    q["user"]?.toString() ?? "",
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
                                      q["role"]?.toString() ?? "",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// LIKE
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    likeQuestion(q["id"]);
                                  },
                                ),

                                Text(
                                  (q["likes"] ?? 0).toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// QUESTION
                        Text(
                          q["question"]?.toString() ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 12),

                        /// ACTIONS
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                openReplies(q["id"]);
                              },
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                              ),
                              label: Text("${q["replies"] ?? 0} Replies"),
                            ),

                            const SizedBox(width: 10),

                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.flag_outlined, size: 18),
                              label: const Text("Report"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      /// QUESTION INPUT
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
