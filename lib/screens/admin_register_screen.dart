import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {

  bool isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController designationController = TextEditingController();

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
                    "Admin Register ✨",
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
                    decoration: inputDecoration("Name", Icons.person),
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

                  // Phone
                  TextFormField(
                    controller: phoneController,
                    decoration: inputDecoration("Phone", Icons.phone),
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
                  SizedBox(height: 20),

                  // Designation
                  TextFormField(
                    controller: designationController,
                    decoration: inputDecoration("Designation", Icons.work),
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
                            await supabase.from('admins').insert([
                              {
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'password': passwordController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'department': selectedDeptId.toString(),
                                'designation': designationController.text.trim(),
                              }
                            ]);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Admin Registered")),
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
                      child: Text("Register", style: TextStyle(color: Colors.white)),
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