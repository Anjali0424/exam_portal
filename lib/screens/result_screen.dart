import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final int examId;
  final int studentId;

  const ResultScreen({
    super.key,
    required this.examId,
    required this.studentId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final supabase = Supabase.instance.client;

  double score = 0;
  double total = 0;  String subject = "";
  String date = "";

  @override
  void initState() {
    super.initState();
    fetchResult();
  }

  Future<void> fetchResult() async {
    final result = await supabase
        .from('student_exams')
        .select()
        .eq('student_id', widget.studentId)
        .eq('exam_id', widget.examId)
        .single();

    final exam = await supabase
        .from('exams')
        .select()
        .eq('exam_id', widget.examId)
        .single();

    setState(() {
      score = (result['score'] is int)
          ? (result['score'] as int).toDouble()
          : (result['score'] ?? 0).toDouble();

      total = (exam['total_marks'] is int)
          ? (exam['total_marks'] as int).toDouble()
          : (exam['total_marks'] ?? 0).toDouble();

      subject = exam['subject'] ?? "N/A";
      date = exam['exam_date'] ?? "N/A";
    });  }

  double get percentage => (score / total) * 100;

  String get grade {
    if (percentage >= 90) return "A";
    if (percentage >= 75) return "B";
    if (percentage >= 50) return "C";
    return "F";
  }

  String get status => percentage >= 40 ? "PASS" : "FAIL";

  // 📄 PDF GENERATION
  Future<void> generatePDF() async {
    final pdf = pw.Document();

    // 📌 LOAD LOGO
    final logo = await imageFromAssetBundle('assets/images/vit_logo.png');

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2),
            ),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // 🏫 HEADER WITH LOGO
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [

                    // LOGO
                    pw.Container(
                      height: 60,
                      width: 60,
                      child: pw.Image(logo),
                    ),

                    pw.SizedBox(width: 15),

                    // COLLEGE NAME
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Vishwakarma Institute of Technology",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "Pune",
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          "Official Examination Marksheet",
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Divider(),

                // 📘 STUDENT + EXAM DETAILS
                pw.Text("Student ID: ${widget.studentId}"),
                pw.Text("Subject: $subject"),
                pw.Text("Date: ${date.toString().split('T')[0]}"),

                pw.SizedBox(height: 20),

                // 📊 MARKS TABLE
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [

                    // HEADER
                    pw.TableRow(
                      decoration:
                      pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Subject"),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Marks"),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Total"),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("Percentage"),
                        ),
                      ],
                    ),

                    // DATA
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(subject),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(score.toStringAsFixed(1)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(total.toStringAsFixed(1)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              "${percentage.toStringAsFixed(1)}%"),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // 🏆 RESULT SUMMARY
                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Grade: $grade",
                        style: pw.TextStyle(fontSize: 14)),
                    pw.Text("Result: $status",
                        style: pw.TextStyle(fontSize: 14)),
                  ],
                ),

                pw.SizedBox(height: 40),

                // ✍ SIGNATURES
                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Student Signature"),
                    pw.Text("Controller of Examination"),
                  ],
                ),

                pw.SizedBox(height: 10),

                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(width: 120, height: 1),
                    pw.Container(width: 160, height: 1),
                  ],
                ),

                pw.SizedBox(height: 20),

                // 📌 FOOTER
                pw.Center(
                  child: pw.Text(
                    "This is a system generated marksheet",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text("Preview PDF"),
            backgroundColor: Color(0xFF034EA1),
          ),
          body: PdfPreview(
            build: (format) => pdf.save(),
          ),
        ),
      ),
    );  }
  // 📤 SHARE
  void shareResult() {
    Share.share(
      "Result:\nSubject: $subject\nScore: ${score.toStringAsFixed(1)}/$total\nPercentage: ${percentage.toStringAsFixed(1)}%",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: const Color(0xFF034EA1),
        title: const Text("Result"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: generatePDF,
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: shareResult,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🎓 HEADER
              Center(
                child: Column(
                  children: [
                    Icon(Icons.emoji_events,
                        size: 80, color: Colors.amber),
                    SizedBox(height: 10),
                    Text(
                      "Exam Report",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034EA1),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Divider(),

              // 📘 DETAILS
              Text("Subject: $subject"),
              Text("Date: ${date.toString().split('T')[0]}"),

              SizedBox(height: 20),

              // 📊 SCORE BOX
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF034EA1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "${score.toStringAsFixed(1)} / ${total.toStringAsFixed(1)}",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034EA1),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // 🏆 RESULT STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Grade: $grade",
                      style: TextStyle(fontSize: 16)),
                  Text(status,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),

              SizedBox(height: 30),

              // 🔽 ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: generatePDF,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF034EA1),
                      ),
                      child: Text("Download PDF",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: shareResult,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text("Share",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}