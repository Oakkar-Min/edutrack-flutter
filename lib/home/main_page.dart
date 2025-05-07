import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_track_project/exam/exam_card.dart';
import 'package:edu_track_project/class/schedule_card.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1E1E2E),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  String getFirestoreDay() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final username = currentUser?.displayName ?? "User";
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(username),

              // Stats Cards
              _buildStatsSection(currentUser),

              // Upcoming Exams
              _buildExamsSection(currentUser),

              // Class Schedule
              _buildClassScheduleSection(currentUser),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String username) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E48),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB388F5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: Color(0xFFB388F5),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM').format(DateTime.now()),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF373750),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, size: 22),
                  color: const Color(0xFFB388F5),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: "Log out",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(User? currentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Task Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Use LayoutBuilder to make the cards responsive
          LayoutBuilder(
            builder: (context, constraints) {
              // Only switch to vertical layout on very small screens (iPhone SE is around 320px wide)
              if (constraints.maxWidth < 360) {
                return Column(
                  children: [
                    _buildStatsCard(
                      "Assignments",
                      FirebaseFirestore.instance
                          .collection('assignments')
                          .where('creator', isEqualTo: currentUser!.uid)
                          .snapshots(),
                      '/assignments',
                      Icons.assignment,
                    ),
                    const SizedBox(height: 16),
                    _buildStatsCard(
                      "Study Planner",
                      FirebaseFirestore.instance
                          .collection('studyTasks')
                          .where('creator', isEqualTo: currentUser.uid)
                          .snapshots(),
                      '/planner',
                      Icons.event_note,
                    ),
                  ],
                );
              } else {
                // Keep horizontal layout for most phones
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        "Assignments",
                        FirebaseFirestore.instance
                            .collection('assignments')
                            .where('creator', isEqualTo: currentUser!.uid)
                            .snapshots(),
                        '/assignments',
                        Icons.assignment,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatsCard(
                        "Study Planner",
                        FirebaseFirestore.instance
                            .collection('studyTasks')
                            .where('creator', isEqualTo: currentUser.uid)
                            .snapshots(),
                        '/planner',
                        Icons.event_note,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      String title, Stream<QuerySnapshot> stream, String route, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          int completed = 0;
          int todo = 0;

          for (var doc in docs) {
            final status =
                (doc.data() as Map<String, dynamic>)['status'] ?? 'Pending';
            status == 'Completed' ? completed++ : todo++;
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E48),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize
                      .min, // Prevent title row from expanding too much
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB388F5).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFFB388F5),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      // Make the title text flexible
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFB388F5),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis for long titles
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem("Completed", completed.toString()),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Expanded(
                      child: _buildStatItem("To Do", todo.toString()),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        FittedBox(
          // Use FittedBox to scale text if needed
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          // Use FittedBox to scale text if needed
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamsSection(User? currentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Upcoming Exams", '/exams'),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exams')
                  .where('creator', isEqualTo: currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFB388F5)),
                    ),
                  );
                }

                List<DocumentSnapshot> exams = snapshot.data!.docs;

                List<DocumentSnapshot> filteredExams = exams.where((exam) {
                  DateTime endTime = (exam['endTime'] as Timestamp)
                      .toDate()
                      .toLocal(); // Add toLocal()
                  return endTime.isAfter(DateTime.now());
                }).toList();

                filteredExams.sort((a, b) {
                  DateTime dateA = (a['examDate'] as Timestamp)
                      .toDate()
                      .toLocal(); // Add toLocal()
                  DateTime dateB =
                      (b['examDate'] as Timestamp).toDate().toLocal();
                  int dateComparison = dateA.compareTo(dateB);
                  if (dateComparison != 0) return dateComparison;

                  DateTime startA = (a['startTime'] as Timestamp)
                      .toDate()
                      .toLocal(); // Add toLocal()
                  DateTime startB =
                      (b['startTime'] as Timestamp).toDate().toLocal();
                  return startA.compareTo(startB);
                });

                if (filteredExams.isEmpty) {
                  return _buildEmptyState(
                    "No upcoming exams",
                    Icons.event_busy,
                    "Great job! You don't have any upcoming exams.",
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredExams.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8),
                  itemBuilder: (context, index) {
                    final exam = filteredExams[index];
                    final data = exam.data() as Map<String, dynamic>;

                    return Container(
                      width: 230,
                      margin: const EdgeInsets.only(right: 16),
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
        ],
      ),
    );
  }

  Widget _buildClassScheduleSection(User? currentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Today's Classes", '/classSchedule'),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .where('day', isEqualTo: getFirestoreDay())
                  .where('creator', isEqualTo: currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFB388F5)),
                    ),
                  );
                }

                final classes = snapshot.data?.docs ?? [];
                if (classes.isEmpty) {
                  return _buildEmptyState(
                    "No classes today",
                    Icons.free_breakfast,
                    "Enjoy your free time today!",
                  );
                }

                final sortedClasses = classes.toList()
                  ..sort((a, b) {
                    final aTime =
                        (a.data() as Map<String, dynamic>)['startTime'] as int;
                    final bTime =
                        (b.data() as Map<String, dynamic>)['startTime'] as int;
                    return aTime.compareTo(bTime);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedClasses.length,
                  itemBuilder: (context, index) {
                    final aClass =
                        sortedClasses[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ScheduleCard(
                        startTime: _formatTime(aClass['startTime']),
                        endTime: _formatTime(aClass['endTime']),
                        subject: aClass['name'] ?? 'No Subject',
                        room: aClass['classroom'] ?? 'No Room',
                        type: aClass['type'] ?? 'No Type',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, route),
          icon: const Icon(
            Icons.arrow_forward,
            color: Color(0xFFB388F5),
            size: 16,
          ),
          label: const Text(
            "View All",
            style: TextStyle(
              color: Color(0xFFB388F5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.white70, size: 24),
            SizedBox(width: 12),
            Text("Log out", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text("Are you sure you want to log out?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFFB388F5))),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Log out"),
          ),
        ],
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
