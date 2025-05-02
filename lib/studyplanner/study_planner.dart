import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edu_track_project/studyplanner/task_card_study.dart';

class StudyPlannerPage extends StatefulWidget {
  const StudyPlannerPage({Key? key}) : super(key: key);

  @override
  State<StudyPlannerPage> createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> {
  String currentFilter = 'All';

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('studyTasks')
            .where('creator',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading tasks", style: TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTasks = snapshot.data!.docs;

          final filteredTasks = allTasks.where((task) {
            final status = task['status'];
            if (currentFilter == 'Completed') return status == 'Completed';
            if (currentFilter == 'Pending') return status == 'Pending';
            return true;
          }).toList();

          final totalTasks = allTasks.length;
          final completedCount = allTasks.where((t) => t['status'] == 'Completed').length;
          final pendingCount = allTasks.where((t) => t['status'] == 'Pending').length;
          final progress = totalTasks == 0 ? 0.0 : completedCount / totalTasks;
          final progressPercent = (progress * 100).toStringAsFixed(0);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Progress summary
                _buildProgressCard(progress, progressPercent, pendingCount, completedCount),

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
                    Text("Showing: $currentFilter", style: const TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterSheet,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_study');
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Task list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final docId = task.id;
                      final title = task['title'];
                      final status = task['status'];
                      final date = (task['createdAt'] as Timestamp).toDate();
                      final dateFormatted = "${date.day}-${date.month}-${date.year}";

                      return Dismissible(
                        key: Key(docId),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          color: const Color.fromARGB(255, 25, 141, 85),
                          child: const Icon(Icons.check_circle, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: const Color.fromARGB(255, 141, 29, 21),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            if (status == 'Pending') {
                              await FirebaseFirestore.instance
                                  .collection('studyTasks')
                                  .doc(docId)
                                  .update({'status': 'Completed'});
                            }
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            final confirm = await _showDeleteConfirmation(context);
                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection('studyTasks')
                                  .doc(docId)
                                  .delete();
                              return true;
                            }
                          }
                          return false;
                        },
                        child: TaskCardStudy(
                          title: title,
                          creationDate: dateFormatted,
                          isCompleted: status == 'Completed',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(double progress, String percent, int pending, int completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Study Progress", style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  color: const Color(0xFFB388F5),
                ),
              ),
              const SizedBox(width: 8),
              Text("$percent%", style: const TextStyle(color: Colors.white)),
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
                Text("Pending\n$pending", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                Text("Completed\n$completed", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E2E48),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterTile("Show All", Icons.all_inbox, 'All'),
            _buildFilterTile("Completed", Icons.check_circle, 'Completed'),
            _buildFilterTile("Pending", Icons.pending_actions, 'Pending'),
          ],
        );
      },
    );
  }

  ListTile _buildFilterTile(String label, IconData icon, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Color(0xFFB388F5))),
      onTap: () {
        Navigator.pop(context);
        setState(() => currentFilter = value);
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E48),
        title: const Text("Delete Task", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this task?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Color(0xFFB388F5))),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
