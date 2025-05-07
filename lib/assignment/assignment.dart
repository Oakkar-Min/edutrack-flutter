import 'package:edu_track_project/assignment/assignment_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_track_project/assignment/task_card_assign.dart';
import 'package:edu_track_project/assignment/add_assignment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AssignmentTrackerPage extends StatefulWidget {
  const AssignmentTrackerPage({Key? key}) : super(key: key);

  @override
  State<AssignmentTrackerPage> createState() => _AssignmentTrackerPageState();
}

class _AssignmentTrackerPageState extends State<AssignmentTrackerPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  CollectionReference get _assignmentsRef =>
      FirebaseFirestore.instance.collection('assignments');

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E2E48),
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 16),
                child: Text(
                  "Filter Assignments",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white24),
              ..._buildFilterOptions(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterOptions() {
    final options = [
      {'label': 'All', 'icon': Icons.all_inbox},
      {'label': 'Pending', 'icon': Icons.pending},
      {'label': 'Completed', 'icon': Icons.check_circle},
      {'label': 'Overdue', 'icon': Icons.warning},
    ];

    return options.map((option) {
      final label = option['label'] as String;
      final icon = option['icon'] as IconData;
      final isSelected = _selectedFilter == label;

      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFB388F5).withOpacity(0.2) 
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFFB388F5) : Colors.white70,
            size: 24,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFB388F5) : Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: Color(0xFFB388F5)) 
            : null,
        onTap: () {
          setState(() => _selectedFilter = label);
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  Future<void> _updateAssignmentStatus(String id, String newStatus) async {
    await _assignmentsRef.doc(id).update({'status': newStatus});
  }

  Future<void> _deleteAssignment(String id) async {
    await _assignmentsRef.doc(id).delete();
  }

  bool _isOverdue(String dateStr) {
    final dueDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(todayStart);
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.greenAccent;
      default:
        return Colors.blueAccent;
    }
  }

  Widget _buildAssignmentTracker(
      int total, int pending, int completed, int overdue) {
    final progress = total == 0 ? 0.0 : completed / total;
    final progressText = '${(progress * 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E2E48), Color(0xFF363654)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB388F5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFFB388F5),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assignment Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$completed of $total assignments completed",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E2E48),
                  border: Border.all(
                    color: const Color(0xFFB388F5),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    progressText,
                    style: const TextStyle(
                      color: Color(0xFFB388F5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Progress",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              color: const Color(0xFFB388F5),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "Pending",
                  pending.toString(),
                  Icons.pending_actions,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "Completed",
                  completed.toString(),
                  Icons.check_circle_outline,
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "Overdue",
                  overdue.toString(),
                  Icons.warning_amber,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: const Color(0xFFB388F5).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? "No assignments yet"
                : "No $_selectedFilter assignments",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? "Add your first assignment"
                : "Try a different filter",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedFilter == 'All')
            ElevatedButton.icon(
              onPressed: () => _navigateToAddAssignmentPage(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Assignment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB388F5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Assignment Tracker",
            style: TextStyle(
              color: Color(0xFFB388F5),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     icon: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: const Color(0xFF2E2E48),
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: const Icon(Icons.add, color: Color(0xFFB388F5)),
          //     ),
          //     onPressed: () => _navigateToAddAssignmentPage(context),
          //   ),
          //   const SizedBox(width: 12),
          // ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _assignmentsRef
              .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: const Color(0xFFB388F5), size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "Error loading assignments",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB388F5)),
                  strokeWidth: 3,
                ),
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
                'dueDateTime': dueDate,
                'link': data['link'],
                'status': status,
              };
            }).toList();

            assignments.sort((a, b) => a['dueDateTime'].compareTo(b['dueDateTime']));

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

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAssignmentTracker(
                        assignments.length, pending, completed, overdue),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          "Assignment List",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _buildFilterChip(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final assignment = filtered[index];
                                final isOverdue = _isOverdue(assignment['date']);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Dismissible(
                                    key: Key(assignment['id']),
                                    background: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 25, 141, 85),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    secondaryBackground: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 141, 29, 21),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      if (direction == DismissDirection.startToEnd) {
                                        await _updateAssignmentStatus(
                                            assignment['id'], 'Completed');
                                        return false;
                                      } else {
                                        final confirm = await _showDeleteConfirmationDialog(context);
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
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToAddAssignmentPage(context),
          backgroundColor: const Color(0xFFB388F5),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    return GestureDetector(
      onTap: _showFilterBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E48),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB388F5).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedFilter,
              style: const TextStyle(
                color: Color(0xFFB388F5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.filter_list,
              color: Color(0xFFB388F5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 16),
            const Text(
              "Delete Assignment", 
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this assignment? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFFB388F5)),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Delete", 
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}