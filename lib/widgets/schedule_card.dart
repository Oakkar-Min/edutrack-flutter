import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String type;

  const ScheduleCard({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
    required this.type,
  }) : super(key: key);

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'online':
        return Colors.greenAccent;
      case 'onsite':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2E2E48),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$startTime - $endTime",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Classroom: $room",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(width: 16),
                Text(
                  "Type: ",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  type,
                  style: TextStyle(
                    color: getTypeColor(type),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
