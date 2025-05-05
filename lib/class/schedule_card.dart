import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String type;

  const ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
    required this.type,
    Key? key,
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
     margin: EdgeInsets.only(bottom: 12),
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
                Expanded(
                  child: Text(
                    "Room: $room",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: getTypeColor(type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: getTypeColor(type),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: getTypeColor(type),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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