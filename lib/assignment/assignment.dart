import 'package:edu_track_project/assignment/assignment_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_track_project/assignment/task_card_assign.dart';
import 'package:edu_track_project/assignment/add_assignment.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentTrackerPage extends StatefulWidget {
  const AssignmentTrackerPage({Key? key}) : super(key: key);

  @override
  State<AssignmentTrackerPage> createState() => _AssignmentTrackerPageState();
}

class _AssignmentTrackerPageState extends State<AssignmentTrackerPage> {
  String _selectedFilter = 'All';

  CollectionReference get _assignmentsRef =>
      FirebaseFirestore.instance.collection('assignments');

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E2E48),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Pending', 'Completed', 'Overdue'].map((status) {
            return ListTile(
              leading: Icon(
                status == 'Completed'
                    ? Icons.check_circle
                    : status == 'Pending'
                        ? Icons.pending
                        : status == 'Overdue'
                            ? Icons.warning
                            : Icons.all_inbox,
                color: Colors.white,
              ),
              title: Text(status,
                  style: const TextStyle(color: Color(0xFFB388F5))),
              onTap: () {
                setState(() => _selectedFilter = status);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _updateAssignmentStatus(String id, String newStatus) async {
    await _assignmentsRef.doc(id).update({'status': newStatus});
  }

  Future<void> _deleteAssignment(String id) async {
    await _assignmentsRef.doc(id).delete();
  }

  bool _isOverdue(String dateStr) {
    final dueDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    return dueDate.isBefore(DateTime.now());
  }

  String _calculatePriority(String dateStr) {
    final dueDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference <= 3) return 'High';
    if (difference <= 7) return 'Medium';
    return 'Low';
  }

  String _calculateStatus(String currentStatus, String dateStr) {
    if (currentStatus == 'Completed') return 'Completed';
    return _isOverdue(dateStr) ? 'Overdue' : 'Pending';
  }

  void _navigateToAddAssignmentPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssignmentPage(),
      ),
    );
  }

  Widget _buildAssignmentTracker(
      int total, int pending, int completed, int overdue) {
    final progress = total == 0 ? 0.0 : completed / total;
    final progressText = '${(progress * 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assignment Progress",
              style: TextStyle(color: Colors.white, fontSize: 16)),
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
              Text(progressText, style: const TextStyle(color: Colors.white)),
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
                Text("Pending\n$pending",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
                Text("Completed\n$completed",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
                Text("Overdue\n$overdue",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Assignment Tracker",
            style: TextStyle(color: Color(0xFFB388F5))),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _assignmentsRef
            .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB388F5)),
            );
          }

          final docs = snapshot.data!.docs;
          final assignments = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;

            final Timestamp dueTimestamp = data['dueDate'];
            final DateTime dueDate = dueTimestamp.toDate();
            final String formattedDate =
                DateFormat('yyyy-MM-dd').format(dueDate);

            final status = _calculateStatus(data['status'], formattedDate);
            final priority = _calculatePriority(formattedDate);

            return {
              'id': id,
              'title': data['title'],
              'priority': priority,
              'date': formattedDate,
              'dueDateTime': dueDate, // 👈 store original DateTime for sorting
              'link': data['link'],
              'status': status,
            };
          }).toList();

// ✅ Sort by due date ascending (earliest first)
          assignments
              .sort((a, b) => a['dueDateTime'].compareTo(b['dueDateTime']));

          final filtered = _selectedFilter == 'All'
              ? assignments
              : assignments
                  .where((a) => a['status'] == _selectedFilter)
                  .toList();

          final pending =
              assignments.where((a) => a['status'] == 'Pending').length;
          final completed =
              assignments.where((a) => a['status'] == 'Completed').length;
          final overdue =
              assignments.where((a) => a['status'] == 'Overdue').length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAssignmentTracker(
                    assignments.length, pending, completed, overdue),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text("Assignment List",
                          style: TextStyle(
                              color: Color(0xFFB388F5),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text("Showing: $_selectedFilter",
                        style: const TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterBottomSheet,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _navigateToAddAssignmentPage(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final assignment = filtered[index];
                      final isOverdue = _isOverdue(assignment['date']);

                      return Dismissible(
                        key: Key(assignment['id']),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          color: const Color.fromARGB(255, 25, 141, 85),
                          child: const Icon(Icons.check_circle,
                              color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: const Color.fromARGB(255, 141, 29, 21),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _updateAssignmentStatus(
                                assignment['id'], 'Completed');
                            return false;
                          } else {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF2E2E48),
                                title: const Text("Delete Assignment",
                                    style: TextStyle(color: Colors.white)),
                                content: const Text(
                                    "Are you sure you want to delete this assignment?",
                                    style: TextStyle(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Color(0xFFB388F5))),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text("Delete",
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteAssignment(assignment['id']);
                              return true;
                            }
                            return false;
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AssignmentDetailDialog(
                                assignmentId: assignment['id'],
                              ),
                            );
                          },
                          child: TaskCard(
                            title: assignment['title'],
                            priority: assignment['priority'],
                            date: assignment['date'],
                            status: assignment['status'],
                            link: assignment['link'],
                            isOverdue: isOverdue,
                          ),
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
}
