import 'package:flutter/material.dart';

class Assignment {
  final String title;
  final String priority;
  final String date;
  final String link;
  bool isCompleted;

  Assignment({
    required this.title,
    required this.priority,
    required this.date,
    required this.link,
    required this.isCompleted,
  });
}

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final List<Assignment> assignments = [
    Assignment(
      title: "CSC 304 Linear Algebra",
      priority: "High",
      date: "12-2-2025",
      link: "https://www.color-hex.com/",
      isCompleted: false,
    ),
    Assignment(
      title: "CSC 305 Data Structures",
      priority: "Medium",
      date: "15-2-2025",
      link: "https://www.color-hex.com/",
      isCompleted: false,
    ),
    Assignment(
      title: "CSC 306 Networks",
      priority: "Low",
      date: "20-2-2025",
      link: "https://www.color-hex.com/",
      isCompleted: false,
    ),
    Assignment(
      title: "CSC 307 Algorithms",
      priority: "High",
      date: "22-2-2025",
      link: "https://www.color-hex.com/",
      isCompleted: false,
    ),
    Assignment(
      title: "CSC 308 AI",
      priority: "Medium",
      date: "25-2-2025",
      link: "https://www.color-hex.com/",
      isCompleted: false,
    ),
    Assignment(
      title: "CSC 309 Machine Learning",
      priority: "Low",
      date: "28-2-2025",
      link: "https://www.color-hex.com/",
      isCompleted: false,
    ),
  ];

  final List<Assignment> completedAssignments = [];

  int get totalCount => assignments.length + completedAssignments.length;
  int get completedCount => completedAssignments.length;
  int get pendingCount => assignments.length;
  double get progressPercentage =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  @override
  Widget build(BuildContext context) {
    assignments.sort(
      (a, b) => _priorityValue(a.priority).compareTo(_priorityValue(b.priority)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB388F5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Assignment', style: TextStyle(color: Colors.white)),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout, color: Color(0xFFB388F5)),
        //     onPressed: () {
        //       setState(() {});
        //     },
        //   ),
        // ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrackerSection(),
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 12),
            _buildAssignmentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB388F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assignment Tracker",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.white24,
                  color: const Color(0xFFB388F5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(progressPercentage * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB388F5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Pending\n$pendingCount", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                Text("Completed\n$completedCount", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                const Text("Overdue\n0", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Assignment List",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Icon(Icons.add_circle_outline, color: Color(0xFFB388F5)),
      ],
    );
  }

  Widget _buildAssignmentList() {
    return Expanded(
      child: ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          final priorityColor = _getPriorityColor(assignment.priority);

          return Dismissible(
            key: Key(assignment.title + index.toString()),
            background: _buildDismissBackground(Colors.redAccent, Alignment.centerLeft, Icons.delete),
            secondaryBackground: _buildDismissBackground(Colors.greenAccent, Alignment.centerRight, Icons.check),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                return await _showDeleteConfirmation(context);
              }
              return true;
            },
            onDismissed: (direction) {
              setState(() {
                if (direction == DismissDirection.endToStart) {
                  completedAssignments.add(assignments.removeAt(index));
                  _showSnackBar('Marked "${assignment.title}" as completed', Colors.green);
                } else {
                  assignments.removeAt(index);
                  _showSnackBar('Deleted "${assignment.title}"', Colors.red);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB388F5)),
              ),
              child: _buildAssignmentDetails(assignment, priorityColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentDetails(Assignment assignment, Color priorityColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: "Priority: ", style: TextStyle(color: Colors.white70)),
                    TextSpan(text: assignment.priority, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
                    TextSpan(text: "    Due Date: ${assignment.date}", style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Link: ${assignment.link}",
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground(Color color, Alignment alignment, IconData icon) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Assignment"),
              content: const Text("Are you sure you want to delete this assignment?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  int _priorityValue(String priority) {
    switch (priority) {
      case "High":
        return 0;
      case "Medium":
        return 1;
      default:
        return 2;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.redAccent;
      case "Medium":
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent;
    }
  }
}
