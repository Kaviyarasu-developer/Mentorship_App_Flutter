import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController questionController = TextEditingController();

  List<Map<String, dynamic>> questions = [
    {
      "user": "Arul",
      "role": "STD",
      "question": "How to learn Spring Boot?",
      "likes": 12,
      "replies": 10,
    },
    {
      "user": "Kavi",
      "role": "MENTOR",
      "question": "What is Dependency Injection?",
      "likes": 5,
      "replies": 2,
    },
  ];

  void addQuestion() {
    if (questionController.text.trim().isEmpty) return;

    setState(() {
      questions.insert(0, {
        "user": "Student",
        "role": "STD",
        "question": questionController.text,
        "likes": 0,
        "replies": 0,
      });
    });

    questionController.clear();
  }

  void likeQuestion(int index) {
    setState(() {
      questions[index]["likes"] = (questions[index]["likes"] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      /// username + role
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

                      /// LIKE BUTTON
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                              size: 22,
                            ),
                            onPressed: () {
                              likeQuestion(index);
                            },
                          ),

                          Center(
                            child: Text(
                              (q["likes"] ?? 0).toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// QUESTION TEXT
                  Text(
                    q["question"]?.toString() ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  /// BOTTOM ACTIONS
                  Row(
                    children: [
                      /// REPLIES
                      TextButton.icon(
                        onPressed: () {
                          // open replies later
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text("${q["replies"] ?? 0} Replies"),
                      ),

                      const SizedBox(width: 10),

                      /// REPORT
                      TextButton.icon(
                        onPressed: () {
                          // report logic later
                        },
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
                onPressed: addQuestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
