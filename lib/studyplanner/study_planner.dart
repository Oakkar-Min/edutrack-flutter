import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_track_project/studyplanner/study_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edu_track_project/studyplanner/task_card_study.dart';
import 'package:flutter/services.dart';

class StudyPlannerPage extends StatefulWidget {
  const StudyPlannerPage({Key? key}) : super(key: key);

  @override
  State<StudyPlannerPage> createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> with SingleTickerProviderStateMixin {
  String currentFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _animation;
  // Add a GlobalKey for the AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  // Add a list to track the current filtered tasks
  List<DocumentSnapshot> _currentFilteredTasks = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
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
            "Study Planner",
            style: TextStyle(
              color: Color(0xFFB388F5),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('studyTasks')
              .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              // Explicitly order by creation time
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFB388F5), size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "Error loading tasks",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB388F5)),
                ),
              );
            }

            final allTasks = snapshot.data!.docs;
            allTasks.sort((a, b) {
              Timestamp timestampA = a['createdAt'];
              Timestamp timestampB = b['createdAt'];
              return timestampB.compareTo(timestampA);
            });

            final filteredTasks = allTasks.where((task) {
              final status = task['status'];
              if (currentFilter == 'Completed') return status == 'Completed';
              if (currentFilter == 'Pending') return status == 'Pending';
              return true;
            }).toList();

            // Update the current filtered tasks list
            // This is important to check for changes in the list
            if (_currentFilteredTasks.length != filteredTasks.length ||
                !_listMatches(_currentFilteredTasks, filteredTasks)) {
              // If this is not the initial load, handle animations
              if (_currentFilteredTasks.isNotEmpty) {
                _handleListChanges(_currentFilteredTasks, filteredTasks);
              } else {
                // Initial load - just set the list
                _currentFilteredTasks = List.from(filteredTasks);
                
                // If we need to rebuild the entire list after filter changes
                if (_listKey.currentState != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _rebuildEntireList(filteredTasks);
                  });
                }
              }
            }

            final totalTasks = allTasks.length;
            final completedCount =
                allTasks.where((t) => t['status'] == 'Completed').length;
            final pendingCount =
                allTasks.where((t) => t['status'] == 'Pending').length;
            final progress = totalTasks == 0 ? 0.0 : completedCount / totalTasks;
            final progressPercent = (progress * 100).toStringAsFixed(0);

            return FadeTransition(
              opacity: _animation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    
                    // Progress summary
                    _buildProgressCard(
                        progress, progressPercent, pendingCount, completedCount),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        const Text(
                          "Study Tasks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _buildFilterDropdown(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Task list
                    Expanded(
                      child: filteredTasks.isEmpty
                          ? _buildEmptyState()
                          : AnimatedList(
                              key: _listKey,
                              initialItemCount: filteredTasks.length,
                              padding: const EdgeInsets.only(bottom: 24),
                              itemBuilder: (context, index, animation) {
                                // Guard against index out of range errors
                                if (index >= filteredTasks.length) {
                                  return const SizedBox.shrink();
                                }
                                
                                final task = filteredTasks[index];
                                final docId = task.id;
                                final title = task['title'];
                                final status = task['status'];
                                final date = (task['createdAt'] as Timestamp).toDate();
                                final dateFormatted =
                                    "${date.day}-${date.month}-${date.year}";

                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  )),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Dismissible(
                                      key: Key(docId),
                                      background: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.only(left: 20),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 25, 141, 85),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                          
                                        child: const Icon(Icons.check_circle,
                                            color: Colors.white),
                                      ),
                                      secondaryBackground: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 141, 29, 21),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
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
                                          final confirm =
                                              await _showDeleteConfirmation(context);
                                          if (confirm == true) {
                                            // Important: Remove the item from the animated list first
                                            _removeItem(index);
                                            
                                            // Then delete from Firestore
                                            await FirebaseFirestore.instance
                                                .collection('studyTasks')
                                                .doc(docId)
                                                .delete();
                                            return false; // Return false to let our animation handle it
                                          }
                                        }
                                        return false;
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  StudyTaskDetailPopup(taskId: docId));
                                        },
                                        child: TaskCardStudy(
                                          title: title,
                                          creationDate: dateFormatted,
                                          isCompleted: status == 'Completed',
                                        ),
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
          onPressed: () {
            Navigator.pushNamed(context, '/add_study');
          },
          backgroundColor: const Color(0xFFB388F5),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // Helper method to check if two lists contain the same items by ID
  bool _listMatches(List<DocumentSnapshot> oldList, List<DocumentSnapshot> newList) {
    if (oldList.length != newList.length) return false;
    
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id) return false;
    }
    
    return true;
  }

  // Helper method to handle changes in the list
  void _handleListChanges(List<DocumentSnapshot> oldList, List<DocumentSnapshot> newList) {
    // If there are too many changes, just rebuild the whole list
    // This avoids complex insert/remove operations that might cause issues
    if ((oldList.length - newList.length).abs() > 1) {
      _rebuildEntireList(newList);
      return;
    }
    
    // Find items that were removed
    final Set<String> newIds = newList.map((doc) => doc.id).toSet();
    final Set<String> oldIds = oldList.map((doc) => doc.id).toSet();
    
    // Check for removed items
    for (int i = oldList.length - 1; i >= 0; i--) {
      if (!newIds.contains(oldList[i].id)) {
        _removeItem(i);
      }
    }
    
    // Handle insertions - usually new tasks will be at the beginning since they're sorted by timestamp
    for (int i = 0; i < newList.length; i++) {
      if (!oldIds.contains(newList[i].id)) {
        _insertItem(i, newList[i]);
      }
    }
    
    // Update the reference to the current list
    _currentFilteredTasks = List.from(newList);
  }
  
  // Helper method to completely rebuild the list
  void _rebuildEntireList(List<DocumentSnapshot> newList) {
    if (_listKey.currentState == null) return;
    
    // Save the current list length
    // final int oldLength = _currentFilteredTasks.length;
    
    // Update our reference
    _currentFilteredTasks = List.from(newList);
    
    // Handle complete list refresh by forcing a rebuild
    setState(() {
      // This will trigger a rebuild with the new list
    });
  }

  // Helper method to remove an item with animation
  void _removeItem(int index) {
    if (_listKey.currentState == null) return;
    
    final removedItem = _currentFilteredTasks[index];
    final title = removedItem['title'];
    final status = removedItem['status'];
    final date = (removedItem['createdAt'] as Timestamp).toDate();
    final dateFormatted = "${date.day}-${date.month}-${date.year}";
    
    // Remove from our tracking list
    _currentFilteredTasks.removeAt(index);
    
    // Remove from the animated list with animation
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCardStudy(
              title: title,
              creationDate: dateFormatted,
              isCompleted: status == 'Completed',
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to insert an item with animation
  void _insertItem(int index, DocumentSnapshot item) {
    if (_listKey.currentState == null) return;
    
    // Insert into our tracking list
    if (index >= _currentFilteredTasks.length) {
      _currentFilteredTasks.add(item);
    } else {
      _currentFilteredTasks.insert(index, item);
    }
    
    // Insert into the animated list with animation
    _listKey.currentState!.insertItem(index);
  }

  Widget _buildProgressCard(
      double progress, String percent, int pending, int completed) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                  Icons.book,
                  color: Color(0xFFB388F5),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Study Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "You've completed $completed tasks",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 60,
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
                    "$percent%",
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
                child: _buildProgressMetricCard(
                  "Pending",
                  pending.toString(),
                  Icons.pending_actions,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressMetricCard(
                  "Completed",
                  completed.toString(),
                  Icons.check_circle_outline,
                  Colors.greenAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetricCard(
      String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return GestureDetector(
      onTap: () {
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
                      "Filter Tasks",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  ...['All', 'Completed', 'Pending'].map((filter) {
                    return ListTile(
                      title: Text(
                        filter,
                        style: TextStyle(
                          color: filter == currentFilter
                              ? const Color(0xFFB388F5)
                              : Colors.white70,
                          fontWeight: filter == currentFilter
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: filter == currentFilter
                          ? const Icon(Icons.check_circle, color: Color(0xFFB388F5))
                          : null,
                      onTap: () {
                        setState(() {
                          currentFilter = filter;
                          // Reset the animated list when filter changes
                          _currentFilteredTasks = [];
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
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
              currentFilter,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_add,
            size: 80,
            color: const Color(0xFFB388F5).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            currentFilter == 'All'
                ? "No study tasks yet"
                : "No ${currentFilter.toLowerCase()} tasks",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentFilter == 'All'
                ? "Add your first study task"
                : "Try a different filter",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (currentFilter == 'All')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add_study');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Task"),
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

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
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
              "Delete Task", 
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this task? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFFB388F5))),
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
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}