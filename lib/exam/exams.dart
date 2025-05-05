import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'exam_card.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Exam Tracker',
            style: TextStyle(color: Color(0xFFB388F5))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsetsDirectional.symmetric(horizontal: 14),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A5A),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFFB388F5).withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('exams')
                    .where('creator', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.hasData
                      ? _getUpcomingExamCount(snapshot.data!.docs)
                      : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB388F5).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment,
                            color: Color(0xFFB388F5), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Upcoming Exams",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "$count",
                            style: const TextStyle(
                              color: Color(0xFFB388F5),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // Section Title + Add Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Upcoming Exam Dates",
                      style: TextStyle(
                        color: Color(0xFFB388F5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_exam');
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Live Firestore Exam List
            Expanded(
              child: _buildExamList(userId),
            ),
          ],
        ),
      ),
    );
  }

int _getUpcomingExamCount(List<DocumentSnapshot> docs) {
  return docs.where((exam) {
    final endTime = (exam['endTime'] as Timestamp).toDate();
    return endTime.isAfter(DateTime.now());
  }).length;
}


  Widget _buildExamList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exams')
          .where('creator', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text("No upcoming exams.",
                style: TextStyle(color: Colors.white70)),
          );
        }

        List<DocumentSnapshot> exams = snapshot.data!.docs;

        List<DocumentSnapshot> filteredExams = exams.where((exam) {
          DateTime endTime = (exam['endTime'] as Timestamp).toDate();
          return endTime.isAfter(DateTime.now());
        }).toList();

        filteredExams.sort((a, b) {
          DateTime dateA = (a['examDate'] as Timestamp).toDate();
          DateTime dateB = (b['examDate'] as Timestamp).toDate();
          int dateComparison = dateA.compareTo(dateB);
          if (dateComparison != 0) return dateComparison;

          DateTime startA = (a['startTime'] as Timestamp).toDate();
          DateTime startB = (b['startTime'] as Timestamp).toDate();
          return startA.compareTo(startB);
        });

        if (filteredExams.isEmpty) {
          return const Center(
            child: Text("No upcoming exams",
                style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          itemCount: filteredExams.length,
          itemBuilder: (context, index) {
            final exam = filteredExams[index];
            final data = exam.data() as Map<String, dynamic>;

            return ExamCard(
              examId: exam.id,
              examType: data['type'] ?? '',
              subject: data['name'] ?? '',
              venue: data['venue'] ?? '',
              date: (data['examDate'] as Timestamp?)
                      ?.toDate()
                      .toLocal()
                      .toString()
                      .split(' ')
                      .first ??
                  '',
              startTime: (data['startTime'] as Timestamp?)
                      ?.toDate()
                      .toLocal()
                      .toString()
                      .split(' ')
                      .last
                      .substring(0, 5) ??
                  '',
              endTime: (data['endTime'] as Timestamp?)
                      ?.toDate()
                      .toLocal()
                      .toString()
                      .split(' ')
                      .last
                      .substring(0, 5) ??
                  '',
              description: data['description'] ?? '',
              onDelete: () async {
                await FirebaseFirestore.instance
                    .collection('exams')
                    .doc(exam.id)
                    .delete();
              },
            );
          },
        );
      },
    );
  }
}
