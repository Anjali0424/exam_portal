import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/mongo_service.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() =>
      _StudentRegisterScreenState();
}

class _StudentRegisterScreenState
    extends State<StudentRegisterScreen> {

  bool isPasswordHidden = true;

  final _formKey = GlobalKey<FormState>();

  final supabase = Supabase.instance.client;

  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  TextEditingController nameController =
  TextEditingController();

  TextEditingController emailController =
  TextEditingController();

  TextEditingController passwordController =
  TextEditingController();

  TextEditingController rollController =
  TextEditingController();

  List<dynamic> departments = [];

  int? selectedDeptId;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  // ✅ Fetch Departments
  Future<void> fetchDepartments() async {
    final data =
    await supabase.from('departments').select();

    setState(() {
      departments = data;
    });
  }

  // ✅ Pick Profile Image
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 40),

                  const Text(
                    "Create Account ✨",

                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF034EA1),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===================================================
                  // ✅ PROFILE IMAGE SECTION
                  // ===================================================

                  Center(
                    child: Column(
                      children: [

                        CircleAvatar(
                          radius: 55,
                          backgroundColor:
                          Colors.grey.shade200,

                          backgroundImage:
                          selectedImage != null
                              ? FileImage(selectedImage!)
                              : null,

                          child: selectedImage == null
                              ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          )
                              : null,
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: pickImage,

                          icon: const Icon(Icons.image),

                          label: const Text(
                            "Select Photo",
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF034EA1),

                            foregroundColor:
                            Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ===================================================
                  // NAME
                  // ===================================================

                  TextFormField(
                    controller: nameController,

                    decoration: inputDecoration(
                      "Full Name",
                      Icons.person,
                    ),

                    validator: (v) =>
                    v!.isEmpty
                        ? "Enter name"
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // ===================================================
                  // EMAIL
                  // ===================================================

                  TextFormField(
                    controller: emailController,

                    decoration: inputDecoration(
                      "Email",
                      Icons.email,
                    ),

                    validator: (v) =>
                    v!.contains("@")
                        ? null
                        : "Invalid email",
                  ),

                  const SizedBox(height: 20),

                  // ===================================================
                  // PASSWORD
                  // ===================================================

                  TextFormField(
                    controller: passwordController,

                    obscureText: isPasswordHidden,

                    decoration: inputDecoration(
                      "Password",
                      Icons.lock,

                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),

                        onPressed: () {
                          setState(() {
                            isPasswordHidden =
                            !isPasswordHidden;
                          });
                        },
                      ),
                    ),

                    validator: (v) =>
                    v!.length < 6
                        ? "Min 6 characters"
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // ===================================================
                  // ROLL NUMBER
                  // ===================================================

                  TextFormField(
                    controller: rollController,

                    decoration: inputDecoration(
                      "Roll Number",
                      Icons.badge,
                    ),

                    validator: (v) =>
                    v!.isEmpty
                        ? "Enter roll number"
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // ===================================================
                  // DEPARTMENT DROPDOWN
                  // ===================================================

                  DropdownButtonFormField<int>(
                    value: selectedDeptId,

                    hint: const Text(
                      "Select Department",
                    ),

                    decoration: InputDecoration(
                      prefixIcon:
                      const Icon(Icons.school),

                      filled: true,
                      fillColor: Colors.grey[100],

                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 18,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: departments.map((dept) {

                      return DropdownMenuItem<int>(
                        value: dept['dept_id'],

                        child: Text(
                          dept['dept_name'],
                        ),
                      );

                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedDeptId = value;
                      });
                    },

                    validator: (value) =>
                    value == null
                        ? "Select department"
                        : null,
                  ),

                  const SizedBox(height: 35),

                  // ===================================================
                  // REGISTER BUTTON
                  // ===================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed: () async {

                        if (_formKey.currentState!
                            .validate()) {

                          try {

                            // ==========================================
                            // ✅ INSERT STUDENT IN SQL
                            // ==========================================

                            final insertedStudent =
                            await supabase
                                .from('students')
                                .insert({

                              'name':
                              nameController.text.trim(),

                              'email':
                              emailController.text.trim(),

                              'password':
                              passwordController.text.trim(),

                              'roll_no':
                              rollController.text.trim(),

                              'dept_id':
                              selectedDeptId,

                            })
                                .select()
                                .single();

                            // ==========================================
                            // ✅ GET GENERATED STUDENT ID
                            // ==========================================

                            String studentId =
                            insertedStudent['student_id']
                                .toString();

                            // ==========================================
                            // ✅ CREATE MONGODB PROFILE
                            // ==========================================

                            await MongoService
                                .insertStudentProfile(
                              studentId: studentId,
                            );

                            // ==========================================
                            // ✅ UPLOAD PHOTO TO GRIDFS
                            // ==========================================

                            if (selectedImage != null) {

                              final photoFileId =
                              await MongoService
                                  .uploadPhotoToGridFS(
                                selectedImage!.path,
                              );

                              // ======================================
                              // ✅ UPDATE PHOTO FILE ID
                              // ======================================

                              await MongoService
                                  .updateStudentPhoto(
                                studentId: studentId,
                                photoFileId:
                                photoFileId.toString(),
                              );
                            }

                            ScaffoldMessenger.of(context)
                                .showSnackBar(

                              const SnackBar(
                                content: Text(
                                  "Registration Successful",
                                ),
                              ),
                            );

                            Navigator.pop(context);

                          } catch (e) {

                            ScaffoldMessenger.of(context)
                                .showSnackBar(

                              SnackBar(
                                content: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF034EA1),
                      ),

                      child: const Text(
                        "Register",

                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pop(context),

                      child: const Text(
                        "Already have an account? Login",

                        style: TextStyle(
                          color: Color(0xFF034EA1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  InputDecoration inputDecoration(
      String hint,
      IconData icon, {
        Widget? suffixIcon,
      }) {

    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.grey[100],

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),

        borderSide: BorderSide.none,
      ),
    );
  }
}