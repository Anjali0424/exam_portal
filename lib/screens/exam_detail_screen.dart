import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExamDetailScreen extends StatefulWidget {
  final int examId;
  final String subject;

  const ExamDetailScreen({
    super.key,
    required this.examId,
    required this.subject,
  });

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  final supabase = Supabase.instance.client;

  List results = [];
  int totalStudents = 0;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    final data = await supabase
        .from('student_exams')
        .select('*, students(name)')
        .eq('exam_id', widget.examId)
        .order('score', ascending: false); // 🔥 leaderboard
    print("Exam ID from screen: ${widget.examId}");

    setState(() {
      results = data;
      totalStudents = data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: const Color(0xFF034EA1),
        title: Text(widget.subject),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔵 TOTAL ATTEMPTS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF034EA1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Attempts",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "$totalStudents",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 LEADERBOARD TITLE
            const Text(
              "Leaderboard 🏆",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF034EA1),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 LEADERBOARD LIST
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("No Attempts Yet"))
                  : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        // 🔢 RANK + NAME
                        Row(
                          children: [
                            Text(
                              "#${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF034EA1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              r['students']['name'],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),

                        // 📊 SCORE
                        Text(
                          "${r['score']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}