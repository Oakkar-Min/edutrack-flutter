import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_track_project/assignment/edit_assignment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssignmentDetailDialog extends StatelessWidget {
  final String assignmentId;

  const AssignmentDetailDialog({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const AlertDialog(
            backgroundColor: Color(0xFF2E2E48),
            title: Text('Error', style: TextStyle(color: Colors.white)),
            content: Text('Assignment not found',
                style: TextStyle(color: Colors.white70)),
          );
        }

        final data = snapshot.data!;
        final dueDate = (data['dueDate'] as Timestamp).toDate();
        final priority = data['priority'];
        final status = data['status'];
        final description = data['description'];
        final isOverdue =
            DateTime.now().isAfter(dueDate) && status != "Completed";

        return AlertDialog(
          backgroundColor: const Color(0xFF2E2E48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Assignment Details",
                    style: TextStyle(color: Color(0xFFB388F5), fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFB388F5)),
                    iconSize: 17,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFB388F5),
                thickness: 2,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _detailText("Priority : ", priority,
                  color: priority == "High"
                      ? Colors.red
                      : priority == "Medium"
                          ? Colors.orange
                          : Colors.green),
              _detailText(
                  "Due-date : ", DateFormat('dd-MM-yyyy').format(dueDate)),
              if ((data['link'] as String).isNotEmpty)
                _detailText("Link : ", data['link'],
                    color: const Color(0xFF80CBC4)),
              _detailText(
                "Status : ",
                isOverdue ? "Overdue" : status,
                color: isOverdue
                    ? Colors.red
                    : status == "Completed"
                        ? Colors.green
                        : Colors.orangeAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                "Description : ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
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
                        Navigator.pop(context); // Close the dialog first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAssignmentPage(
                              assignmentId: assignmentId,
                              assignmentData:
                                  data.data() as Map<String, dynamic>,
                            ),
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
                        await FirebaseFirestore.instance
                            .collection('assignments')
                            .doc(assignmentId)
                            .delete();
                        Navigator.of(context).pop();
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
        );
      },
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
}
