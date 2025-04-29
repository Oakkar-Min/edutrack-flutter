import 'package:edu_track_project/auth/splash_page.dart';
import 'package:edu_track_project/exam/exams.dart';
import 'package:edu_track_project/home/assignment.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'home/main_page.dart';
import 'home/study_planner.dart';
import 'home/class_schedule.dart';
import 'package:edu_track_project/exam/add_exam_page.dart';
import 'package:edu_track_project/exam/edit_exam_page.dart';
import 'auth/auth_wrapper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu Track',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white12,
          hintStyle: TextStyle(color: Colors.white54),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB388F5),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        // '/': (context) => const SplashPage(),
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainPage(),
        '/assignments': (context) =>  const AssignmentTrackerPage(),
        '/planner': (context) => const StudyPlannerPage(), 
        '/exams': (context) => const ExamPage(),
        '/classSchedule': (context) => const ClassSchedulePage(), 
        '/add_exam': (context) => const AddExamPage(),
        '/edit_exam': (context) => const EditExamPage(),
      },
    );
  }
}
