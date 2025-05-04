import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_track_project/class/schedule_card.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  String selectedDay = DateFormat('E').format(DateTime.now());
  final todayDate = DateFormat('EEEE , yyyy-MM-dd').format(DateTime.now());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting class: $e')),
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
        title: const Text('Class Schedule',
            style: TextStyle(color: Color(0xFFB388F5))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: classesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  }

                  final classes = snapshot.data!.docs;
                  final sortedClasses = classes.toList()
                    ..sort((a, b) {
                      final aTime = (a.data()
                          as Map<String, dynamic>)['startTime'] as int;
                      final bTime = (b.data()
                          as Map<String, dynamic>)['startTime'] as int;
                      return aTime.compareTo(bTime);
                    });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2E48),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's date : $todayDate",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You have ${classes.length} classes on $selectedDay.",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                              .map((day) => _dayButton(day))
                              .toList(),
                          _addButton(), // Plus button
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: sortedClasses.length,
                          itemBuilder: (context, index) {
                            final doc = sortedClasses[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return Dismissible(
                              key: Key(doc.id),
                              direction: DismissDirection.horizontal,
                              background: _buildSwipeBackground(true),
                              secondaryBackground: _buildSwipeBackground(false),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  final Map<String, dynamic> classDataForEdit =
                                      {
                                    'docId': doc.id,
                                    'name': data['name'],
                                    'classroom': data['classroom'],
                                    'type': data['type'],
                                    'day': data['day'],
                                    'startTime': data['startTime'],
                                    'endTime': data['endTime'],
                                    // Add any other fields needed for editing
                                  };

                                  Navigator.pushNamed(
                                    context,
                                    '/edit_class',
                                    arguments: classDataForEdit,
                                  );
                                  return false;
                                }
                                final confirm = await _showDeleteConfirmation(
                                    context, data['name']);
                                if (confirm) await _deleteClass(doc.id);
                                return confirm;
                              },
                              child: ScheduleCard(
                                startTime: _formatTime(data['startTime']),
                                endTime: _formatTime(data['endTime']),
                                subject: data['name'],
                                room: data['classroom'],
                                type: data['type'],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayButton(String day) {
    final isSelected = day == selectedDay;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedDay = day),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFB388F5) : const Color(0xFF2E2E48),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: const Icon(Icons.add, size: 18, color: Colors.white),
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.pushNamed(context, '/add_class'),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF2E2E48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isEdit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEdit ? Colors.blue.shade800 : Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isEdit ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String subject) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2E2E48),
            title: const Text(
              "Delete Class",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Are you sure you want to delete $subject ?",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.white70)),
              ),
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
