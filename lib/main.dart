import 'package:campus_catalogue/add_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:campus_catalogue/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:campus_catalogue/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  fetch_categories();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'campus_catalogue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => SplashScreen(),
      },
    );
  }
}
