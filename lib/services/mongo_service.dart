import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class MongoService {
  static late Db db;

  static Future<void> connect() async {
    db = await Db.create(
      "mongodb+srv://madhu:Madhusudan@cluster0.c6mvqdo.mongodb.net/vit_marksheet?retryWrites=true&w=majority&appName=Cluster0",
    );

    await db.open();

    print("MongoDB Connected");
  }

  static Future<void> insertStudentProfile({
    required String studentId,
  }) async {
    var collection = db.collection('student_profiles');

    await collection.insertOne({
      "studentId": studentId,
      "createdAt": DateTime.now().toIso8601String(),
    });

    print("✅ Student Profile Created");
  }



  static Future<void> fetchStudentProfile(String studentId) async {
    var collection = db.collection('student_profiles');

    var student = await collection.findOne(
      where.eq("studentId", studentId),
    );

    print(student);
  }

  static Future<void> updateStudentPhoto({
    required String studentId,
    required String photoFileId,
  }) async {
    var collection = db.collection('student_profiles');

    await collection.updateOne(
      where.eq("studentId", studentId),
      modify.set("photoFileId", photoFileId),
    );

    print("✅ Photo Updated");
  }

  static Future<dynamic> uploadPhotoToGridFS(
      String filePath) async {

    final file = File(filePath);

    final gridFS = GridFS(db);

    final gridIn = gridFS.createFile(
      file.openRead(),
      file.uri.pathSegments.last,
    );

    await gridIn.save();

    print("✅ Photo Uploaded");
    print("File ID: ${gridIn.id}");

    return gridIn.id;
  }
  static Future<List<int>?> getImageFromGridFS(
      String fileId) async {

    final gridFS = GridFS(db);

    final gridOut = await gridFS.findOne(
      where.id(ObjectId.parse(fileId)),
    );

    if (gridOut == null) {
      return null;
    }

    // create temporary file
    final tempFile = File(
      '${Directory.systemTemp.path}/temp_image',
    );

    // write GridFS file to temp file
    await gridOut.writeToFile(tempFile);

    // read bytes back
    final bytes = await tempFile.readAsBytes();

    return bytes;
  }
  static Future<Map<String, dynamic>?>
  getStudentProfile(String studentId) async {

    var collection = db.collection('student_profiles');

    final student = await collection.findOne(
      where.eq("studentId", studentId),
    );

    if (student == null) {
      return null;
    }

    return Map<String, dynamic>.from(student);
  }
  static Future<void> uploadAssetToGridFS() async {
    final data = await rootBundle.load('assets/images/vit_logo.png');

    final bytes = data.buffer.asUint8List();

    final gridFS = GridFS(db);

    final gridIn = gridFS.createFile(
      Stream.value(bytes),
      'vit_logo.png',
    );

    await gridIn.save();

    print("✅ Asset Uploaded");
    print("File ID: ${gridIn.id}");
  }


  static Future<dynamic> uploadVideoToGridFS(
      String filePath) async {

    try {

      // RECONNECT IF CLOSED
      if (!db.isConnected) {

        await connect();
      }

      final file = File(filePath);

      print("Video Path: ${file.path}");

      print("Video Size: ${await file.length()}");

      final gridFS = GridFS(db);

      final gridIn = gridFS.createFile(
        file.openRead(),
        file.uri.pathSegments.last,
      );

      await gridIn.save();

      print("✅ Video Uploaded");

      print("Video File ID: ${gridIn.id}");

      return gridIn.id;

    } catch (e) {

      print("UPLOAD VIDEO ERROR: $e");

      return null;
    }
  }

  static Future<void> saveExamVerification({
    required String studentId,
    required String examId,
    required String videoFileId,
  }) async {

    var collection = db.collection(
      'exam_verifications',
    );

    await collection.insertOne({
      "studentId": studentId,
      "examId": examId,
      "videoFileId": videoFileId,
      "capturedAt": DateTime.now()
          .toIso8601String(),
    });

    print("✅ Verification Saved");
  }
}