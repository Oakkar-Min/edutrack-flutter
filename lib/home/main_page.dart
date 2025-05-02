import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_track_project/exam/exam_card.dart';
import 'package:edu_track_project/class/schedule_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, String>> exams = List.generate(5, (index) {
    return {
      'examType': index % 2 == 0 ? 'Module1' : 'Module2',
      'subject': 'CSC ${101 + index}',
      'venue': 'Room ${201 + index}',
      'date': '${index + 1 < 10 ? '0' : ''}${index + 1}-05-2025',
      'time': '10:${index + 1}0 AM',
    };
  });

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('d MMMM, yyyy').format(DateTime.now());

    // Get current user from Firebase Authentication
    User? currentUser = FirebaseAuth.instance.currentUser;
    String username = currentUser?.displayName ?? "Username";

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentDate,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.school,
                    color: const Color(0xFFB388F5),
                    size: 30,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      "Hey, $username !",
                      style: const TextStyle(
                        color: Color(0xFFB388F5),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('assignments').where('creator',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snapshot.data!.docs;

                      // Count completed and to-do (pending or overdue) assignments
                      int completed = 0;
                      int todo = 0;

                      for (var doc in docs) {
                        final data = doc.data();
                        final String status = data['status'] ?? 'Pending';

                        if (status == 'Completed') {
                          completed++;
                        } else {
                          todo++;
                        }
                      }

                      return _buildCard(
                        context,
                        "Assignment",
                        completed.toString(),
                        todo.toString(),
                        '/assignments',
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                 StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('studyTasks').where('creator',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snapshot.data!.docs;

                      // Count completed and to-do (pending or overdue) study tasks
                      int completed = 0;
                      int todo = 0;

                      for (var doc in docs) {
                        final data = doc.data();
                        final String status = data['status'] ?? 'Pending';

                        if (status == 'Completed') {
                          completed++;
                        } else {
                          todo++;
                        }
                      }

                      return _buildCard(
                        context,
                        "Study Planner",
                        completed.toString(),
                        todo.toString(),
                        '/planner',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Upcoming exams", '/exams'),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return ExamCard(
                      examType: exam['examType']!,
                      subject: exam['subject']!,
                      venue: exam['venue']!,
                      date: exam['date']!,
                      time: exam['time']!,
                      fromMainPage: true,
                      onDelete: () {
                        // Placeholder: Implement Firestore delete logic here.
                        // Delete logic is handled in ExamCard
                        setState(() {
                          exams.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, "Class schedule", '/classSchedule'),
              Expanded(
                flex: 5,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ScheduleCard(
                      startTime: "8:00",
                      endTime: "12:00",
                      subject: "CSC 304 Linear Algebra",
                      room: "CB2312",
                      type: index % 2 == 0 ? "Online" : "Onsite",
                    );
                  },
                ),
              ),
            ],
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
              // Sign out from Firebase Authentication
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
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
                      style: TextStyle(color: Colors.white70,fontSize: 18)),
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
                  const Text("To Do", style: TextStyle(color: Colors.white70,fontSize:18 )),
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
              color: Color(0xFFB388F5),
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
