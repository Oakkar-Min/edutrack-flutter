import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_track_project/exam/exam_card.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('d MMMM, yyyy').format(DateTime.now());
    User? currentUser = FirebaseAuth.instance.currentUser;
    String username = currentUser?.displayName ?? "Username";

    final dummyExam = {
      'subject': 'CSC 304 Linear Algebra',
      'examType': 'Midterm',
      'venue': 'CB2308',
      'date': '22-10-2025',
      'time': '10:00 AM',
    };

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hey, $username !",
                      style: const TextStyle(
                        color: Color(0xFFB388F5),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFFB388F5)),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildCard(
                        context, "Assignment", "16", "5", '/assignments'),
                    const SizedBox(width: 12),
                    _buildCard(context, "Study Planner", "10", "5", '/planner'),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle(context, "Upcoming exams", '/exams'),
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 180, // Adjust based on ExamCard height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        1, // Will be replaced with Firestore length later
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 250, // Optional: keeps all cards same width
                          child: ExamCard(
                            examType: dummyExam['examType']!,
                            subject: dummyExam['subject']!,
                            venue: dummyExam['venue']!,
                            date: dummyExam['date']!,
                            time: dummyExam['time']!,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _sectionTitle(context, "Class schedule", '/classSchedule'),
                Column(
                  children: List.generate(5, (index) => _classCard()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text("Log out", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String completed,
      String todo, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E48),
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color: Color(0xFFB388F5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$title",
                  style: const TextStyle(
                      color: Color(0xFFB388F5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(completed,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const Text("Completed",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(todo,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const Text("To Do", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFFB388F5),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, route),
          child: const Text(
            "View all >>",
            style: TextStyle(
              color: Color(0xFFB388F5), // brighter or primary color
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  // Widget _examCard() {
  //   return Container(
  //     height: 160,
  //     margin: const EdgeInsets.symmetric(horizontal: 8),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF2E2E48),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: const [
  //         Text("CSC 304 Linear Algebra",
  //             style:
  //                 TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //         SizedBox(height: 4),
  //         Text("Type: Midterm", style: TextStyle(color: Colors.white70)),
  //         Text("Date: 22-10-2025", style: TextStyle(color: Colors.white70)),
  //         Text("Venue: CB2308", style: TextStyle(color: Colors.white70)),
  //       ],
  //     ),
  //   );
  // }

  Widget _classCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Color(0xFFB388F5), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 60,
            child: Text("8:00\n-\n12:00",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("CSC 304 Linear Algebra",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Classroom : CB2312",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
