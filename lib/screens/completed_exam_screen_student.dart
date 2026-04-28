import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'result_screen.dart';

class CompletedExamScreenStudent extends StatefulWidget {
  final int studentId;

  const CompletedExamScreenStudent({super.key, required this.studentId});

  @override
  State<CompletedExamScreenStudent> createState() =>
      _CompletedExamScreenStudentState();
}

class _CompletedExamScreenStudentState
    extends State<CompletedExamScreenStudent> {

  final supabase = Supabase.instance.client;
  List exams = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedExams();
  }

  Future<void> fetchCompletedExams() async {

    final data = await supabase
        .from('student_exams')
        .select('*, exams(*)')
        .eq('student_id', widget.studentId);

    setState(() {
      exams = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return exams.isEmpty
        ? Center(child: Text("No Completed Exams"))
        : ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {

        final exam = exams[index]['exams'];
        final double score =
        (exams[index]['score'] ?? 0).toDouble();
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  examId: exam['exam_id'],
                  studentId: widget.studentId,
                ),
              ),
            );
          },

          child: Container(
            margin: EdgeInsets.only(bottom: 14),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // SUBJECT + SCORE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      exam['subject'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034EA1),
                      ),
                    ),

                    Text(
                      "${score.toStringAsFixed(1)} Marks",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )                  ],
                ),

                SizedBox(height: 10),

                Text("Date: ${exam['exam_date']}"),
                Text("Time: ${exam['start_time']} - ${exam['end_time']}"),
              ],
            ),
          ),
        );
      },
    );
  }
}