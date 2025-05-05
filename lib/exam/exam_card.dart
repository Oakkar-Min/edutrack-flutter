import 'package:edu_track_project/exam/edit_exam_page.dart';
import 'package:flutter/material.dart';

class ExamCard extends StatelessWidget {
  final String examId;
  final String examType;
  final String subject;
  final String venue;
  final String date;
  final String startTime;
  final String endTime;
  final String description;
  final VoidCallback? onDelete;

  const ExamCard({
    super.key,
    required this.examId,
    required this.examType,
    required this.subject,
    required this.venue,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.onDelete,
  });
  void _showExamDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Exam Details",
                  style: TextStyle(color: Color(0xFFB388F5), fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFB388F5)),
                  iconSize: 17,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Color(0xFFB388F5), thickness: 2),
          ],
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _detailText("Type : ", examType),
              _detailText("Date : ", date),
              _detailText("Time : ", "$startTime - $endTime"),
              _detailText("Venue : ", venue),
              const SizedBox(height: 12),
              const Text(
                "Description : ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description.isNotEmpty ? description : "No description provided.",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              const Divider(color: Color(0xFFB388F5), thickness: 2),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: const Size(90, 20),
                      backgroundColor: const Color(0xFFB388F5),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditExamPage(examId: examId),
                        ),
                      );
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: const Size(90, 20),
                      backgroundColor: const Color(0xFFB388F5),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF2E2E48),
                          title: const Text("Delete Exam",
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              "Are you sure you want to delete this exam?",
                              style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel",
                                  style: TextStyle(color: Color(0xFFB388F5))),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        Navigator.pop(context); // Close the main dialog
                        if (onDelete != null) onDelete!();
                      }
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailText(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showExamDetailsDialog(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0,right: 10),
        
        child: Card(
          color: const Color(0xFF2E2E48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(examType,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(subject,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Venue: $venue",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text("Time: $startTime - $endTime",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
