import 'package:flutter/material.dart';
import 'package:edu_track_project/widgets/task_card_assign.dart';

class AssignmentTrackerPage extends StatelessWidget {
  const AssignmentTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Assignment Tracker",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Tracker Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildAssignmentTracker(),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Assignment List",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Assignment Card
            Expanded(
              flex: 5,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: 5, // 5 dummy tasks
                itemBuilder: (context, index) {
                  return TaskCard(
                    title: "CSC 304 Linear Algebra",
                    priority: index % 2 == 0 ? "High" : "Medium", 
                    date: "12-2-2025",
                    link: "https://www.example.com",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Color(0xFFB388F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assignment Tracker",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.3, // Dummy progress
                  backgroundColor: Colors.white24,
                  color: Color(0xFFB388F5),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "30%",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
              // border: Border.all(color: Color(0xFFB388F5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text(
                  "Pending\n10",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Completed\n21",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Overdue\n1",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
