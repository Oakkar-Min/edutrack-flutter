import 'package:flutter/material.dart';
import 'package:edu_track_project/widgets/task_card_study.dart';

// Make sure to import or copy the TaskCard widget too!

class StudyPlannerPage extends StatelessWidget {
  const StudyPlannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Study Planner",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Study Progress Tracker
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                      "Study Progress",
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
                            value: 0.5, // Dummy progress
                            backgroundColor: Colors.white24,
                            color: Color(0xFFB388F5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "50%",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:  Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                        // border: Border.all(color: Color(0xFFB388F5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text(
                            "Pending\n5",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Completed\n7",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Overdue\n0",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Study Tasks",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // One Dummy Study Task using TaskCard
            Expanded(
              flex: 5,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: 5, // 5 dummy tasks
                itemBuilder: (context, index) {
                  return TaskCardStudy(
                    title: "CSC 304 Linear Algebra",
                    creationDate: "12-2-2025",
                    isCompleted: index % 2 == 0 ? false : true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
