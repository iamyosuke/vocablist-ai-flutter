import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'utils/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 環境変数の読み込み
  await dotenv.load();

  // Supabaseの初期化
  await Supabase.initialize(
    url: 'https://tfbtqtcxqjboaklraeyl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmYnRxdGN4cWpib2FrbHJhZXlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxODM5MzUsImV4cCI6MjA1Nzc1OTkzNX0.nzewuWiAKgZWoOMDjPIT5sUhQ7Te9uxB2D1KbqMKqlU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocablist AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  } 
}
