import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_track_project/class/schedule_card.dart';
import 'package:flutter/services.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> with SingleTickerProviderStateMixin {
  String selectedDay = DateFormat('E').format(DateTime.now());
  final todayDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  
  final List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Set status bar color to match app theme
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1A1A2E),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> get classesStream {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('classes')
        .where('creator', isEqualTo: user.uid)
        .where('day', isEqualTo: selectedDay)
        .snapshots();
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  Future<void> _deleteClass(String docId) async {
    try {
      await _firestore.collection('classes').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class deleted successfully'),
          backgroundColor: Color(0xFF2E2E48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting class: $e'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Class Schedule',
          style: TextStyle(
            color: Color(0xFFB388F5),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: classesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
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

            final classes = snapshot.data!.docs;
            final sortedClasses = classes.toList()
              ..sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['startTime'] as int;
                final bTime = (b.data() as Map<String, dynamic>)['startTime'] as int;
                return aTime.compareTo(bTime);
              });

            return Column(
              children: [
                _buildSummaryCard(classes.length),
                const SizedBox(height: 20),
                _buildDaySelector(),
                const SizedBox(height: 16),
                _buildClassesList(sortedClasses),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_class'),
        backgroundColor: const Color(0xFFB388F5),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: "Add New Class",
      ),
    );
  }

  Widget _buildSummaryCard(int classCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E48),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB388F5).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFB388F5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: classCount.toString(),
                              style: const TextStyle(
                                color: Color(0xFFB388F5),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: classCount == 1 ? " class" : " classes",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: " on $selectedDay",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: weekdays.map((day) => _dayButton(day)).toList(),
      ),
    );
  }

  Widget _dayButton(String day) {
    final isSelected = day == selectedDay;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: isSelected ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB388F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB388F5).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => selectedDay = day),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassesList(List<QueryDocumentSnapshot> classes) {
    if (classes.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "No classes scheduled for $selectedDay",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/add_class'),
                icon: const Icon(Icons.add),
                label: const Text("Add Class"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB388F5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Added bottom padding for FAB
        itemCount: classes.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final doc = classes[index];
          final data = doc.data() as Map<String, dynamic>;

          return _buildClassCard(doc.id, data);
        },
      ),
    );
  }

  Widget _buildClassCard(String docId, Map<String, dynamic> data) {
    return Hero(
      tag: 'class_$docId',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Dismissible(
          key: Key(docId),
          direction: DismissDirection.horizontal,
          background: _buildSwipeBackground(true),
          secondaryBackground: _buildSwipeBackground(false),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              final Map<String, dynamic> classDataForEdit = {
                'docId': docId,
                'name': data['name'],
                'classroom': data['classroom'],
                'type': data['type'],
                'day': data['day'],
                'startTime': data['startTime'],
                'endTime': data['endTime'],
              };

              Navigator.pushNamed(
                context,
                '/edit_class',
                arguments: classDataForEdit,
              );
              return false;
            }
            
            final confirm = await _showDeleteConfirmation(context, data['name']);
            if (confirm) await _deleteClass(docId);
            return confirm;
          },
           child: ScheduleCard(
            startTime: _formatTime(data['startTime']),
            endTime: _formatTime(data['endTime']),
            subject: data['name'],
            room: data['classroom'],
            type: data['type'],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isEdit ? const Color(0xFF2D6CDF) : Colors.red.shade800,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEdit ? Icons.edit : Icons.delete,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            isEdit ? "Edit" : "Delete",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String subject) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2E2E48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                const Text(
                  "Delete Class",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to delete $subject?",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Delete",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ) ??
        false;
  }
}