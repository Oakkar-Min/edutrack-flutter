import 'package:flutter/material.dart';
import 'package:edu_track_project/class/schedule_card.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  // Sample static data for now – replace with Firestore data later
  final List<Map<String, String>> _scheduleList = List.generate(5, (index) {
    return {
      'startTime': '8:00',
      'endTime': '12:00',
      'subject': 'CSC 304 Linear Algebra',
      'room': 'CB2312',
      'type': index % 2 == 0 ? 'Online' : 'Onsite',
    };
  });

  // TODO: Load schedules from Firestore in initState
  // @override
  // void initState() {
  //   super.initState();
  //   fetchScheduleFromFirestore();
  // }

  // Future<void> fetchScheduleFromFirestore() async {
  //   // Fetch data and setState to update _scheduleList
  // }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's date :",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "20-2-2025 (Wednesday)",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You have 5 classes to attend today.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _dayButton("Sat"),
                _dayButton("Mon"),
                _dayButton("Tue"),
                _dayButton("Wed", isSelected: true),
                _dayButton("Thu"),
                _dayButton("Fri"),
                _dayButton("Sun"),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_class');
                    // TODO: After adding, refresh list with setState
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _scheduleList.length,
                itemBuilder: (context, index) {
                  final schedule = _scheduleList[index];
                  return Dismissible(
                    key:UniqueKey(),
                    direction: DismissDirection.horizontal,
                    background: _buildSwipeBackground(true),
                    secondaryBackground: _buildSwipeBackground(false),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // Edit
                        Navigator.pushNamed(
                          context,
                          '/edit_class',
                          arguments: schedule,
                        );
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        final confirm = await _showDeleteConfirmation(
                            context, schedule['subject']!);
                        if (confirm) {
                          setState(() {
                            _scheduleList.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Class deleted')),
                          );
                        }
                        return confirm;
                      }
                      return false;
                    },
                    child: ScheduleCard(
                      startTime: schedule['startTime']!,
                      endTime: schedule['endTime']!,
                      subject: schedule['subject']!,
                      room: schedule['room']!,
                      type: schedule['type']!,
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

  Widget _dayButton(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromARGB(255, 106, 66, 218)
            : const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isEdit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEdit
            ? const Color.fromARGB(255, 20, 86, 161)
            : Colors.red.shade800,
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
              textAlign: TextAlign.start,
            ),
            content: Text(
              "Are you sure you want to delete $subject?",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.deepPurpleAccent)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Delete",
                    style: TextStyle(color: Color.fromARGB(255, 231, 39, 39))),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
