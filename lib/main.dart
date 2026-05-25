import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/SplashScreen.dart';
import 'services/mongo_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOAD ENV
  await dotenv.load(fileName: ".env");

  // SUPABASE INIT
  await Supabase.initialize(

    url: dotenv.env['SUPABASE_URL']!,

    anonKey:
    dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // SUCCESS MESSAGE
  debugPrint(
    "✅ Supabase connected successfully!",
  );

  // MONGODB CONNECT
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