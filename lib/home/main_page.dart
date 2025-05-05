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
  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  String getFirestoreDay() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Mon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final username = currentUser?.displayName ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.school, color: const Color(0xFFB388F5), size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMM').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Hello, $username!",
                        style: const TextStyle(
                          color: Color(0xFFB388F5),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 24),
                    color: const Color(0xFFB388F5),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      "Assignments",
                      FirebaseFirestore.instance
                          .collection('assignments')
                          .where('creator', isEqualTo: currentUser!.uid)
                          .snapshots(),
                          '/assignments'
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      "Study Planner",
                      FirebaseFirestore.instance
                          .collection('studyTasks')
                          .where('creator', isEqualTo: currentUser.uid)
                          .snapshots(),
                          '/planner'
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upcoming Exams
              _buildSectionHeader("Upcoming Exams", '/exams'),
              const SizedBox(height: 16),
              SizedBox(
                height: 182,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('exams')
                      .where('creator', isEqualTo: currentUser.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final exams = snapshot.data?.docs ?? [];
                    final filteredExams = exams.where((exam) {
                      final endTime = exam['endTime'] as Timestamp?;
                      return endTime?.toDate().isAfter(DateTime.now()) ?? false;
                    }).toList()
                      ..sort((a, b) {
                        final dateA = (a['examDate'] as Timestamp?)?.toDate() ?? DateTime(0);
                        final dateB = (b['examDate'] as Timestamp?)?.toDate() ?? DateTime(0);
                        return dateA.compareTo(dateB);
                      });

                    if (filteredExams.isEmpty) {
                      return const Center(
                        child: Text('No upcoming exams',
                            style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return ListView.builder(
                     
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredExams.length,
                      itemBuilder: (context, index) {
                        final exam = filteredExams[index];
                        final data = exam.data() as Map<String, dynamic>;

                        return Container(
                          
                          width: 260,
                     
                          child: ExamCard(
                            examId: exam.id,
                            examType: data['type'] ?? 'No Type',
                            subject: data['name'] ?? 'No Subject',
                            venue: data['venue'] ?? 'No Venue',
                            date: (data['examDate'] as Timestamp?)
                                    ?.toDate()
                                    .toString()
                                    .split(' ')
                                    .first ??
                                '',
                            startTime: (data['startTime'] as Timestamp?)
                                    ?.toDate()
                                    .toString()
                                    .split(' ')
                                    .last
                                    .substring(0, 5) ??
                                '--:--',
                            endTime: (data['endTime'] as Timestamp?)
                                    ?.toDate()
                                    .toString()
                                    .split(' ')
                                    .last
                                    .substring(0, 5) ??
                                '--:--',
                            description: data['description'] ?? 'No Description',
                            onDelete: () async {
                              await FirebaseFirestore.instance
                                  .collection('exams')
                                  .doc(exam.id)
                                  .delete();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Class Schedule
              _buildSectionHeader("Today's Classes", '/classSchedule'),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('classes')
                      .where('day', isEqualTo: getFirestoreDay())
                      .where('creator', isEqualTo: currentUser.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final classes = snapshot.data?.docs ?? [];
                    if (classes.isEmpty) {
                      return Center(
                          child: Text('No classes today!',
                              style: TextStyle(color: Colors.white70)));
                    }

                    final sortedClasses = classes.toList()
                      ..sort((a, b) {
                        final aTime = (a.data() as Map<String, dynamic>)['startTime'] as int;
                        final bTime = (b.data() as Map<String, dynamic>)['startTime'] as int;
                        return aTime.compareTo(bTime);
                      });

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: sortedClasses.length,
                      itemBuilder: (context, index) {
                        final aClass = sortedClasses[index].data() as Map<String, dynamic>;
                        return ScheduleCard(
                          startTime: _formatTime(aClass['startTime']),
                          endTime: _formatTime(aClass['endTime']),
                          subject: aClass['name'] ?? 'No Subject',
                          room: aClass['classroom'] ?? 'No Room',
                          type: aClass['type'] ?? 'No Type',
                        );
                      },
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

  Widget _buildStatsCard(String title, Stream<QuerySnapshot> stream, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          int completed = 0;
          int todo = 0;
      
          for (var doc in docs) {
            final status = (doc.data() as Map<String, dynamic>)['status'] ?? 'Pending';
            status == 'Completed' ? completed++ : todo++;
          }
      
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E48),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFB388F5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow("Completed", completed.toString()),
                const SizedBox(height: 8),
                _buildStatRow("To Do", todo.toString()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFB388F5),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, route),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: const Text(
            "View All",
            style: TextStyle(
              color: Color(0xFFB388F5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Color(0xFFB388F5))),),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}