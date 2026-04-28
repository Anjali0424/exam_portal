import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {

  bool isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rollController = TextEditingController();

  List<dynamic> departments = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 40),

                  Text(
                    "Create Account ✨",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF034EA1),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Name
                  TextFormField(
                    controller: nameController,
                    decoration: inputDecoration("Full Name", Icons.person),
                    validator: (v) =>
                    v!.isEmpty ? "Enter name" : null,
                  ),

                  SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: inputDecoration("Email", Icons.email),
                    validator: (v) =>
                    v!.contains("@") ? null : "Invalid email",
                  ),

                  SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: isPasswordHidden,
                    decoration: inputDecoration(
                      "Password",
                      Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                    ),
                    validator: (v) =>
                    v!.length < 6 ? "Min 6 characters" : null,
                  ),

                  SizedBox(height: 20),

                  // Roll No
                  TextFormField(
                    controller: rollController,
                    decoration: inputDecoration("Roll Number", Icons.badge),
                    validator: (v) =>
                    v!.isEmpty ? "Enter roll number" : null,
                  ),

                  SizedBox(height: 20),

                  // 🎯 Department Dropdown
                  DropdownButtonFormField<int>(
                    value: selectedDeptId,
                    hint: Text("Select Department"),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.school),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: departments.map((dept) {
                      return DropdownMenuItem<int>(
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

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await supabase.from('students').insert({
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'password': passwordController.text.trim(),
                              'roll_no': rollController.text.trim(),
                              'dept_id': selectedDeptId, // ✅ important
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Registration Successful")),
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
                      child: Text("Register", style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Color(0xFF034EA1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}