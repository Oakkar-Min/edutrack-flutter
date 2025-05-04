import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_track_project/studyplanner/edit_study.dart';
import 'package:flutter/material.dart';

class StudyTaskDetailPopup extends StatelessWidget {
  final String taskId;

  const StudyTaskDetailPopup({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('studyTasks').doc(taskId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const AlertDialog(
            backgroundColor: Color(0xFF2E2E48),
            title: Text('Error', style: TextStyle(color: Colors.white)),
            content: Text('Task not found', style: TextStyle(color: Colors.white70)),
          );
        }

        final task = snapshot.data!;
        final title = task['title'];
        final status = task['status'];
        final description = task['description'] ?? '';
        final createdAt = (task['createdAt'] as Timestamp).toDate();
        final createdAtFormatted = "${createdAt.day}-${createdAt.month}-${createdAt.year}";

        return AlertDialog(
          backgroundColor: const Color(0xFF2E2E48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Task Details",
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _detailText("Creation Date : ", createdAtFormatted),
              _detailText("Status : ", status,
                  color: status == 'Completed' ? Colors.green : Colors.orange),
              const SizedBox(height: 12),
              const Text(
                "Description : ",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description.isNotEmpty ? description : "No description provided.",
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
                        Navigator.pop(context);
                        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditTaskPage(taskId: taskId),
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
                            title: const Text("Delete Task", style: TextStyle(color: Colors.white)),
                            content: const Text("Are you sure you want to delete this task?", style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel", style: TextStyle(color: Color(0xFFB388F5))),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance.collection('studyTasks').doc(taskId).delete();
                          Navigator.pop(context);
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
