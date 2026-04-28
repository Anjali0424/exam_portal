import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {

  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  TextEditingController subjectController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController totalQuestionsController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List departments = [];
  int? selectedDeptId;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    final data = await supabase.from('departments').select();
    setState(() {
      departments = data;
    });
  }

  // 📅 Date Picker
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ⏰ Time Picker
  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("Create Exam"),
        backgroundColor: Color(0xFF034EA1),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Subject
              TextFormField(
                controller: subjectController,
                decoration: inputDecoration("Subject", Icons.book),
                validator: (v) => v!.isEmpty ? "Enter subject" : null,
              ),

              SizedBox(height: 20),

              // Marks
              TextFormField(
                controller: marksController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration("Total Marks", Icons.score),
                validator: (v) => v!.isEmpty ? "Enter marks" : null,
              ),

              SizedBox(height: 20),

              // Duration
              TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration("Duration (minutes)", Icons.timer),
                validator: (v) => v!.isEmpty ? "Enter duration" : null,
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: totalQuestionsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Number of Questions",
                  prefixIcon: Icon(Icons.format_list_numbered),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter number of questions" : null,
              ),

              SizedBox(height: 20),

              // 📅 Date
              ListTile(
                title: Text(
                  selectedDate == null
                      ? "Select Date"
                      : selectedDate.toString().split(" ")[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: pickDate,
              ),

              // ⏰ Start Time
              ListTile(
                title: Text(
                  startTime == null
                      ? "Start Time"
                      : startTime!.format(context),
                ),
                trailing: Icon(Icons.access_time),
                onTap: pickStartTime,
              ),

              // ⏰ End Time
              ListTile(
                title: Text(
                  endTime == null
                      ? "End Time"
                      : endTime!.format(context),
                ),
                trailing: Icon(Icons.access_time),
                onTap: pickEndTime,
              ),

              SizedBox(height: 20),

              // 🎯 Department Dropdown
              DropdownButtonFormField<int>(
                value: selectedDeptId,
                hint: Text("Select Department"),
                decoration: inputDecoration("Department", Icons.school),
                items: departments.map<DropdownMenuItem<int>>((dept) {
                  return DropdownMenuItem(
                    value: dept['dept_id'],
                    child: Text(dept['dept_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDeptId = value;
                  });
                },
                validator: (value) =>
                value == null ? "Select department" : null,
              ),

              SizedBox(height: 30),

              // 🔵 Create Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()
                        && selectedDate != null
                        && startTime != null
                        && endTime != null) {

                      final startMinutes = startTime!.hour * 60 + startTime!.minute;
                      final endMinutes = endTime!.hour * 60 + endTime!.minute;

                      final difference = endMinutes - startMinutes;

                      if (difference > 20) {
                        bool? proceed = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Warning"),
                            content: Text("Exam access duration exceeds 20 minutes. Continue?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text("Continue"),
                              ),
                            ],
                          ),
                        );

                        if (proceed != true) return;
                      }

                      try {
                        await supabase.from('exams').insert({
                          'subject': subjectController.text.trim(),
                          'total_marks': int.parse(marksController.text),
                          'duration': int.parse(durationController.text),
                          'exam_date': selectedDate.toString(),

                          // ✅ FIXED FORMAT (IMPORTANT)
                          'start_time': "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}",
                          'end_time': "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}",

                          'dept_id': selectedDeptId,
                          'total_questions': int.parse(totalQuestionsController.text),

                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Exam Created Successfully")),
                        );

                        Navigator.pop(context);

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
                  child: Text("Create Exam",
                      style: TextStyle(color: Colors.white)),
                ),
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