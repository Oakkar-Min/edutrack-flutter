import 'package:flutter/material.dart';
import 'package:edu_track_project/studyplanner/task_card_study.dart';

class StudyPlannerPage extends StatefulWidget {
  const StudyPlannerPage({Key? key}) : super(key: key);

  @override
  State<StudyPlannerPage> createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> {
  String currentFilter = 'All';

  // TODO: Replace this list with Firestore query later
  List<Map<String, dynamic>> taskList = [
    {
      "title": "CSC 304 Linear Algebra",
      "date": "12-2-2025",
      "status": "Pending",
    },
    {
      "title": "CSC 304 Linear Algebra",
      "date": "12-2-2025",
      "status": "Completed",
    },
    {
      "title": "CSC 304 Linear Algebra",
      "date": "12-2-2025",
      "status": "Pending",
    },
    {
      "title": "CSC 304 Linear Algebra",
      "date": "12-2-2025",
      "status": "Completed",
    },
    {
      "title": "CSC 304 Linear Algebra",
      "date": "12-2-2025",
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        taskList.where((task) => task['status'] == 'Pending').length;
    final completedCount =
        taskList.where((task) => task['status'] == 'Completed').length;
    final totalTasks = taskList.length;
    final progress = totalTasks == 0 ? 0.0 : completedCount / totalTasks;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    final filteredTasks = taskList.where((task) {
      if (currentFilter == 'Completed') return task['status'] == 'Completed';
      if (currentFilter == 'Pending') return task['status'] == 'Pending';
      return true; // 'All'
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Study Planner",
          style: TextStyle(color: Color(0xFFB388F5)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E48),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Study Progress",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress, // TODO: Replace with Firestore data
                          backgroundColor: Colors.white24,
                          color: const Color(0xFFB388F5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$progressPercent%",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Pending\n$pendingCount",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Completed\n$completedCount",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Study Tasks",
                    style: TextStyle(
                      color: Color(0xFFB388F5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Showing: $currentFilter",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF2E2E48),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.all_inbox,
                                  color: Colors.white),
                              title: const Text("Show All",
                                  style: TextStyle(color: Color(0xFFB388F5))),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  currentFilter = 'All';
                                });
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              title: const Text("Completed",
                                  style: TextStyle(color: Color(0xFFB388F5))),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  currentFilter = 'Completed';
                                });
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.pending_actions,
                                  color: Colors.white),
                              title: const Text("Pending",
                                  style: TextStyle(color: Color(0xFFB388F5))),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  currentFilter = 'Pending';
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_study').then((_) {
                      // TODO: After navigating back, refresh tasks from Firestore
                      setState(() {});
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Apply filtering based on currentFilter

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];

                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      color: const Color.fromARGB(255, 25, 141, 85),
                      child:
                          const Icon(Icons.check_circle, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: const Color.fromARGB(255, 141, 29, 21),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final originalIndex = taskList
                          .indexOf(task); // Get actual index in taskList

                      if (direction == DismissDirection.startToEnd) {
                        if (task['status'] == 'Pending') {
                          setState(() {
                            taskList[originalIndex]['status'] = 'Completed';
                          });
                          return false; // Mark as complete, don't dismiss
                        }
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF2E2E48),
                            title: const Text("Delete Task",
                                style: TextStyle(color: Colors.white)),
                            content: const Text(
                                "Are you sure you want to delete this task?",
                                style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 136, 88, 218)),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            taskList.removeAt(originalIndex);
                          });
                          return true;
                        }
                        return false;
                      }
                      return false;
                    },
                    child: TaskCardStudy(
                      title: task['title'],
                      creationDate: task['date'],
                      isCompleted: task['status'] == 'Completed',
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
}
