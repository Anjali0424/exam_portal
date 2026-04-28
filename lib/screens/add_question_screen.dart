import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddQuestionScreen extends StatefulWidget {
  final int examId;
  final int totalMarks;
  final int totalQuestions;



  const AddQuestionScreen({
    super.key,
    required this.examId,
    required this.totalMarks,
    required this.totalQuestions

  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {

  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  int addedQuestions = 0;



  TextEditingController questionController = TextEditingController();
  TextEditingController optionAController = TextEditingController();
  TextEditingController optionBController = TextEditingController();
  TextEditingController optionCController = TextEditingController();
  TextEditingController optionDController = TextEditingController();

  String? correctAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Question"),
        backgroundColor: Color(0xFF034EA1),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // Question
              TextFormField(
                controller: questionController,
                decoration: inputDecoration("Question", Icons.help),
                validator: (v) => v!.isEmpty ? "Enter question" : null,
              ),

              SizedBox(height: 20),

              // Options
              TextFormField(
                controller: optionAController,
                decoration: inputDecoration("Option A", Icons.circle),
              ),

              SizedBox(height: 15),

              TextFormField(
                controller: optionBController,
                decoration: inputDecoration("Option B", Icons.circle),
              ),

              SizedBox(height: 15),

              TextFormField(
                controller: optionCController,
                decoration: inputDecoration("Option C", Icons.circle),
              ),

              SizedBox(height: 15),

              TextFormField(
                controller: optionDController,
                decoration: inputDecoration("Option D", Icons.circle),
              ),

              SizedBox(height: 20),

              Text(
                "Questions: $addedQuestions / ${widget.totalQuestions}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF034EA1),
                ),
              ),

              SizedBox(height: 20),

              // Correct Answer Dropdown
              DropdownButtonFormField<String>(
                value: correctAnswer,
                hint: Text("Select Correct Answer"),
                items: ["A", "B", "C", "D"].map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text("Option $opt"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    correctAnswer = value;
                  });
                },
                validator: (v) => v == null ? "Select correct answer" : null,
              ),

              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: addedQuestions >= widget.totalQuestions
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    try {

                      await supabase.from('questions').insert({
                        'exam_id': widget.examId,
                        'question': questionController.text.trim(),
                        'option_a': optionAController.text.trim(),
                        'option_b': optionBController.text.trim(),
                        'option_c': optionCController.text.trim(),
                        'option_d': optionDController.text.trim(),
                        'correct_answer': correctAnswer,
                      });

                      setState(() {
                        addedQuestions++; // ✅ COUNT INCREASE
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Question $addedQuestions added")),
                      );

                      // CLEAR FIELDS
                      questionController.clear();
                      optionAController.clear();
                      optionBController.clear();
                      optionCController.clear();
                      optionDController.clear();
                      correctAnswer = null;

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF034EA1),
                ),
                child: Text("Add Question", style: TextStyle(color: Colors.white)),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: addedQuestions == widget.totalQuestions
                    ? () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Finish Exam"),
                      content: Text("All questions added. Submit exam?"),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context); // go back
                          },
                          child: Text("Submit"),
                        ),
                      ],
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text("Finish Exam", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}