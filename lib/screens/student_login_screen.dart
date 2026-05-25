import 'package:exam_portal/screens/student_dashboard_screen.dart';
import 'package:exam_portal/screens/student_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});


  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {

  bool isPasswordHidden = true; // 🔥 state variable
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;


  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 40),

                // 🔥 Title
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF034EA1),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Login to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 40),

                // 📧 Email Field
                TextFormField(
                  controller: emailController,
                  decoration: inputDecoration("Email", Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!value.contains("@")) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // 🔒 Password Field with toggle
                TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: inputDecoration(
                    "Password",
                    Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30),

                // 🔵 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final response = await supabase
                              .from('students')
                              .select()
                              .eq('email', emailController.text.trim())
                              .eq('password', passwordController.text.trim())
                              .single();

                          debugPrint("LOGIN RESPONSE => $response");


                          // ✅ USE response HERE ONLY
                          String userName = response['name'];
                          int deptId = response['dept_id'];

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDashboardScreen(
                                name: response['name'],
                                studentId: response['student_id'], // ✅ ADD THIS
                                deptId: response['dept_id'],
                              )
                            ),
                          );

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Invalid Email or Password")),
                          );
                        }
                      }
                    },                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF034EA1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // 🆕 Register Link
// 🆕 Register Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // 🚀 Navigate to Register Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentRegisterScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Adds a larger touch area
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: Color(0xFF034EA1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      contentPadding: EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}