import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/SplashScreen.dart';
import 'services/mongo_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kijhyvbsqahycpuxyvbw.supabase.co',
    anonKey: 'sb_publishable_12V-1X3l7IQOdsXyfMbmzw_-TGmSSxj',
  );

  // ✅ PRINT SUCCESS MESSAGE
  debugPrint("✅ Supabase is connected successfully!");

  await MongoService.connect();

  runApp(const MyApp());
}

// ✅ global client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam Portal',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: SplashScreen(),
    );
  }
}