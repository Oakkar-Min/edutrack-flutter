import 'package:flutter/material.dart';

class StudyTask {
  final String title;
  final String creationDate;
  bool isCompleted;

  StudyTask({
    required this.title,
    required this.creationDate,
    this.isCompleted = false,
  });
}

class StudyPlannerPage extends StatefulWidget {
  const StudyPlannerPage({super.key});

  @override
  State<StudyPlannerPage> createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> {
  String _selectedFilter = 'All';

  final List<StudyTask> tasks = [
    StudyTask(title: "CSC 304 Linear Algebra", creationDate: "12-2-2025"),
    StudyTask(title: "CSC 305 Data Structures", creationDate: "14-2-2025"),
    StudyTask(title: "CSC 306 Networks", creationDate: "18-2-2025"),
  ];


  int get totalCount => tasks.length;
  int get completedCount => tasks.where((task) => task.isCompleted).length;
  int get pendingCount => tasks.where((task) => !task.isCompleted).length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;


Widget _buildFilterDropdown() {
  return DropdownButton<String>(
    value: _selectedFilter,
    dropdownColor: const Color(0xFF2C2C2E),
    style: const TextStyle(color: Colors.white),
    icon: const Icon(Icons.filter_list, color: Color(0xFFB388F5)),
    underline: Container(), // Remove default underline
    items: ['All', 'Pending', 'Completed'].map((filter) {
      return DropdownMenuItem<String>(
        value: filter,
        child: Text(
          filter,
          style: const TextStyle(fontSize: 14),
        ),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        _selectedFilter = value!;
      });
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Completed') return task.isCompleted;
      if (_selectedFilter == 'Pending') return !task.isCompleted;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB388F5)),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('Study Planner', style: TextStyle(color: Colors.white)),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout, color: Color(0xFFB388F5)),
        //     onPressed: () {},
        //   ),
        // ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTracker(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Study Task List",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFFB388F5)),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildFilterDropdown(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No tasks found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Dismissible(
                          key: Key(task.title + index.toString()),
                          background: _buildDismissBackground(
                              Colors.green, Alignment.centerRight, Icons.check),
                          secondaryBackground: _buildDismissBackground(
                              Colors.redAccent,
                              Alignment.centerLeft,
                              Icons.delete),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await _confirmDelete(task.title);
                            }
                            return true;
                          },
                          onDismissed: (direction) {
                            setState(() {
                              if (direction == DismissDirection.startToEnd) {
                                final completedTask = tasks.removeAt(index);
                                completedTask.isCompleted=true;
                                tasks.add(completedTask);
                              } else {
                                tasks.removeAt(index);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1C1E),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFB388F5)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(task.title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Creation Date: ${task.creationDate}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Status: ${task.isCompleted ? "Completed" : "Pending"}",
                                        style: TextStyle(
                                          color: task.isCompleted
                                              ? Colors.greenAccent
                                              : Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildTracker() {
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
          const Text("Study Tracker",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
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
              Text("${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(color: Colors.white)),
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
                Text("Pending\n$pendingCount",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
                Text("Completed\n$completedCount",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white)),
          
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(
      Color color, Alignment alignment, IconData icon) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }

  Future<bool> _confirmDelete(String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Task"),
            content: Text("Are you sure you want to delete \"$title\"?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
