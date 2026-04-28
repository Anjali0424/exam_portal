import 'package:exam_portal/screens/add_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduledExamsScreen extends StatefulWidget {
  const ScheduledExamsScreen({super.key});

  @override
  State<ScheduledExamsScreen> createState() => _ScheduledExamsScreenState();
}

class _ScheduledExamsScreenState extends State<ScheduledExamsScreen> {

  final supabase = Supabase.instance.client;
  List exams = [];

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    final data = await supabase
        .from('exams')
        .select('*, departments(dept_name)')
        .order('exam_date', ascending: true);

    setState(() {
      exams = data.where((exam) {

        final start = DateTime.parse(
          "${exam['exam_date']}T${exam['start_time']}",
        );

        final end = DateTime.parse(
          "${exam['exam_date']}T${exam['end_time']}",
        );

        final now = DateTime.now();

        return now.isBefore(end); // ✅ upcoming + ongoing
      }).toList();
    });  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Scheduled Exams"),
        backgroundColor: const Color(0xFF034EA1),
      ),

      body: exams.isEmpty
          ? const Center(child: Text("No Exams Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];

          final now = DateTime.now();

          final start = DateTime.parse(
            "${exam['exam_date']}T${exam['start_time']}",
          );

          final end = DateTime.parse(
            "${exam['exam_date']}T${exam['end_time']}",
          );

          bool isUpcoming = now.isBefore(start);
          bool isOngoing = now.isAfter(start) && now.isBefore(end);

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 📘 Subject
                Text(
                  exam['subject'] ?? 'No Subject',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF034EA1),
                  ),
                ),

                const SizedBox(height: 10),

                // 📅 Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(exam['exam_date'] ?? ''),
                  ],
                ),

                const SizedBox(height: 5),

                // ⏰ Time
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 8),
                    Text("${exam['start_time']} - ${exam['end_time']}"),
                  ],
                ),

                const SizedBox(height: 5),

                // 📊 Marks
                Row(
                  children: [
                    const Icon(Icons.score, size: 16),
                    const SizedBox(width: 8),
                    Text("Marks: ${exam['total_marks']}"),
                  ],
                ),

                const SizedBox(height: 5),

                // 🏫 Department
                Row(
                  children: [
                    const Icon(Icons.school, size: 16),
                    const SizedBox(width: 8),
                    Text("Dept: ${exam['departments']?['dept_name'] ?? 'N/A'}"),
                  ],
                ),

                const SizedBox(height: 15),

                // 🔥 Add Questions Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUpcoming
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddQuestionScreen(
                            examId: exam['exam_id'],
                            totalMarks: exam['total_marks'],
                            totalQuestions: exam['total_questions'] ?? 0,
                          ),
                        ),
                      );
                    }
                        : null, // ❌ disables button
                    style: ElevatedButton.styleFrom(
                  backgroundColor: isUpcoming
                  ? Color(0xFF034EA1)
                      : Colors.grey,
                    ),
                    child: Text(
                      "Add Questions",
                      style: TextStyle(color: Colors.white),
                    ),
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