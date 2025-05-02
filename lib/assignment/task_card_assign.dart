import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String priority;
  final String date;
  final String link;
  final String status;
  final bool isOverdue;

  const TaskCard({
    Key? key,
    required this.title,
    required this.priority,
    required this.date,
    required this.link,
    required this.status,
    required this.isOverdue,
  }) : super(key: key);

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2E2E48),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Priority: ",
                    style: TextStyle(color: Colors.white70)),
                Text(
                  priority,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getPriorityColor(priority),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Due Date: $date",
              style: TextStyle(
                color: isOverdue ? Colors.redAccent : Colors.white70,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Link: $link",
              style: const TextStyle(color: Colors.blueAccent),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              "Status: $status",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
