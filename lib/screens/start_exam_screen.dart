
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/mongo_service.dart';

class StartExamScreen extends StatefulWidget {
final int examId;
final int studentId;

const StartExamScreen({
super.key,
required this.examId,
required this.studentId,
});

@override
State<StartExamScreen> createState() =>
_StartExamScreenState();
}

class _StartExamScreenState
extends State<StartExamScreen> {

final supabase = Supabase.instance.client;

int remainingSeconds = 0;

Timer? timer;

List questions = [];

int currentIndex = 0;

bool isSubmitted = false;

Map<int, String> answers = {};

double marksPerQuestion = 1;

// =========================================================
// VIDEO VERIFICATION VARIABLES
// =========================================================

CameraController? cameraController;

bool isRecordingVideo = false;

@override
void initState() {
super.initState();

checkAttempt();
}

// =========================================================
// CHECK ALREADY ATTEMPTED
// =========================================================

Future<bool> hasAttempted() async {

final data = await supabase
    .from('student_exams')
    .select()
    .eq('student_id', widget.studentId)
    .eq('exam_id', widget.examId);

return data.isNotEmpty;
}

void checkAttempt() async {

bool attempted = await hasAttempted();

if (attempted) {

showDialog(
context: context,
barrierDismissible: false,

builder: (_) => AlertDialog(
title: const Text(
"Already Attempted",
),

content: const Text(
"You cannot attempt this exam again.",
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
Navigator.pop(context);
},

child: const Text("OK"),
)
],
),
);

} else {

fetchQuestions();
}
}

// =========================================================
// VIDEO VERIFICATION RECORDING
// =========================================================

Future<void> startVerificationRecording() async {

try {

final cameras = await availableCameras();

final frontCamera = cameras.firstWhere(
      (camera) =>
  camera.lensDirection ==
      CameraLensDirection.front,
);
cameraController = CameraController(
frontCamera,
ResolutionPreset.low,
enableAudio: true,
);

await cameraController!.initialize();

setState(() {
isRecordingVideo = true;
});

// START RECORDING
await cameraController!
    .startVideoRecording();

// RECORD FOR 3 SECONDS
await Future.delayed(
const Duration(seconds: 3),
);

// STOP RECORDING
final XFile videoFile =
await cameraController!
    .stopVideoRecording();

setState(() {
isRecordingVideo = false;
});

// =====================================================
// UPLOAD VIDEO TO GRIDFS
// =====================================================

final videoFileId =
await MongoService.uploadVideoToGridFS(
videoFile.path,
);

// =====================================================
// SAVE VERIFICATION METADATA
// =====================================================

await MongoService.saveExamVerification(
studentId:
widget.studentId.toString(),

examId:
widget.examId.toString(),

videoFileId:
videoFileId.toString(),
);

print("✅ Verification Complete");

} catch (e) {

print("Video Error: $e");
}
}

// =========================================================
// FETCH QUESTIONS + MARKS
// =========================================================

Future<void> fetchQuestions() async {

final examData = await supabase
    .from('exams')
    .select()
    .eq('exam_id', widget.examId)
    .single();

final questionData = await supabase
    .from('questions')
    .select()
    .eq('exam_id', widget.examId);

if (questionData.isEmpty) {

setState(() {
questions = [];
});

return;
}

final totalMarks =
examData['total_marks'] ?? 0;

setState(() {

questions = questionData;

remainingSeconds =
(examData['duration'] ?? 0) * 60;

marksPerQuestion = questions.isNotEmpty
? totalMarks / questions.length
    : 0;
});

// =====================================================
// START 3-SECOND VIDEO VERIFICATION
// =====================================================

await startVerificationRecording();

// =====================================================
// START EXAM TIMER
// =====================================================

startTimer();
}

// =========================================================
// TIMER
// =========================================================

void startTimer() {

timer = Timer.periodic(
const Duration(seconds: 1),
(t) {

if (remainingSeconds > 0) {

setState(() {
remainingSeconds--;
});

} else {

t.cancel();
submitExam();
}
},
);
}

@override
void dispose() {

timer?.cancel();

cameraController?.dispose();

super.dispose();
}

// =========================================================
// SUBMIT EXAM
// =========================================================

void submitExam() async {

if (isSubmitted) return;

isSubmitted = true;

timer?.cancel();

double score = 0;

for (int i = 0;
i < questions.length;
i++) {

final correct =
questions[i]['correct_answer'];

final selected = answers[i];

if (selected == correct) {
score += marksPerQuestion;
}
}

try {

await supabase
    .from('student_exams')
    .insert({

'student_id': widget.studentId,

'exam_id': widget.examId,

'score': score,
});

} catch (e) {

debugPrint(
"Insert error: $e",
);
}

showDialog(
context: context,
barrierDismissible: false,

builder: (_) => AlertDialog(

title: const Text(
"Exam Submitted",
),

content: Text(
"Score: ${score.toStringAsFixed(1)}",
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
Navigator.pop(context);
},

child: const Text("OK"),
)
],
),
);
}

// =========================================================
// FORMAT TIMER
// =========================================================

String formatTime(int seconds) {

final minutes = seconds ~/ 60;

final secs = seconds % 60;

return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
}

@override
Widget build(BuildContext context) {

if (questions.isEmpty) {

return Scaffold(

appBar: AppBar(
backgroundColor:
const Color(0xFF034EA1),

title: const Text(
"Exam",
style: TextStyle(
color: Colors.white,
),
),
),

body: const Center(
child: Text(
"No Questions Available",
),
),
);
}

final q = questions[currentIndex];

return WillPopScope(

onWillPop: () async => false,

child: Scaffold(
backgroundColor: Colors.grey[100],

appBar: AppBar(
backgroundColor:
const Color(0xFF034EA1),

title: Text(
"Q ${currentIndex + 1}/${questions.length}",

style: const TextStyle(
color: Colors.white,
),
),

actions: [

if (isRecordingVideo)
const Padding(
padding: EdgeInsets.only(right: 12),

child: Center(
child: Row(
children: [

Icon(
Icons.fiber_manual_record,
color: Colors.red,
size: 18,
),

SizedBox(width: 5),

Text(
"Verifying",
style: TextStyle(
color: Colors.white,
fontWeight:
FontWeight.bold,
),
),
],
),
),
),

Padding(
padding:
const EdgeInsets.only(right: 16),

child: Center(
child: Text(
formatTime(remainingSeconds),

style: const TextStyle(
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
),
)
],
),

body: Padding(
padding: const EdgeInsets.all(16),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// QUESTION
Text(
q['question'] ?? "",

style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

// OPTIONS
optionTile(
"A",
q['option_a'],
),

optionTile(
"B",
q['option_b'],
),

optionTile(
"C",
q['option_c'],
),

optionTile(
"D",
q['option_d'],
),

const Spacer(),

// BUTTON
SizedBox(
width: double.infinity,

child: ElevatedButton(
onPressed: () {

if (answers[currentIndex] == null) {

ScaffoldMessenger.of(context)
    .showSnackBar(

const SnackBar(
content: Text(
"Select an option",
),
),
);

return;
}

if (currentIndex <
questions.length - 1) {

setState(() {
currentIndex++;
});

} else {

submitExam();
}
},

style: ElevatedButton.styleFrom(
backgroundColor:
const Color(0xFF034EA1),
),

child: Text(
currentIndex ==
questions.length - 1
? "Submit"
    : "Next",

style: const TextStyle(
color: Colors.white,
),
),
),
)
],
),
),
),
);
}

// =========================================================
// OPTION TILE
// =========================================================

Widget optionTile(
String key,
String? text,
) {

final isSelected =
answers[currentIndex] == key;

return GestureDetector(

onTap: () {

setState(() {
answers[currentIndex] = key;
});
},

child: Container(
margin:
const EdgeInsets.only(bottom: 12),

padding: const EdgeInsets.all(14),

decoration: BoxDecoration(
color: isSelected
? const Color(0xFF034EA1)
    .withOpacity(0.1)
    : Colors.white,

borderRadius:
BorderRadius.circular(12),

border: Border.all(
color: isSelected
? const Color(0xFF034EA1)
    : Colors.grey.shade300,
),
),

child: Text(text ?? ""),
),
);
}
}

