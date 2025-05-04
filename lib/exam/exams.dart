import 'package:flutter/material.dart';
import 'exam_card.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final List<Map<String, String>> _examList = List.generate(5, (index) {
    return {
      'examType': index % 2 == 0 ? 'Module1' : 'Module2',
      'subject': 'CSC 304 Linear Algebra',
      'venue': 'CB2312',
      'date': '20-2-2025',
      'time': '13:30',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Exam Tracker', style: TextStyle(color: Color(0xFFB388F5))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exam Details",
                      style: TextStyle(
                        color: Color(0xFFB388F5),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "You have 8 upcoming exams.\nClosest exam date: 6-10-2025",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section Title + Add Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            // List of Exams with Dismissible Logic
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _examList.length,
                itemBuilder: (context, index) {
                  final exam = _examList[index];

                  return Dismissible(
                     key: UniqueKey(),
                    direction: DismissDirection.horizontal,
                    background: _buildSwipeBackground(isEdit: true),
                    secondaryBackground: _buildSwipeBackground(isEdit: false),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // Edit
                        Navigator.pushNamed(
                          context,
                          '/edit_exam',
                          arguments: exam,
                        );
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        // Delete
                        return await _showDeleteConfirmation(context, exam['subject'] ?? '');
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      setState(() {
                        _examList.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exam deleted')),
                      );
                    },
                    child: ExamCard(
                      examType: exam['examType']!,
                      subject: exam['subject']!,
                      venue: exam['venue']!,
                      date: exam['date']!,
                      time: exam['time']!,
                      fromMainPage: false,
                    ),
                  );
                },
              ),
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isEdit}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEdit
            ? const Color.fromARGB(255, 20, 86, 161)
            : const Color.fromARGB(255, 141, 29, 21),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isEdit ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String subject) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2E2E48),
            title: const Text(
              "Delete Exam",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Are you sure you want to delete the exam for $subject?",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.deepPurpleAccent)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Delete", style: TextStyle(color: Color.fromARGB(255, 231, 39, 39))),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
