import 'package:flutter/material.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  String selectedDay = 'Wed';

  final Map<String, List<Map<String, String>>> classSchedule = {
    'Mon': [
      {
        'time': '9:00 - 10:30',
        'title': 'Math 101',
        'room': 'Room A1',
        'type': 'Offline',
      },
    ],
    'Tue': [
      {
        'time': '11:00 - 12:30',
        'title': 'History 201',
        'room': 'Room B2',
        'type': 'Online',
      },
    ],
    'Wed': [
      {
        'time': '8:00 - 12:00',
        'title': 'CSC 304 Linear Algebra',
        'room': 'CB2312',
        'type': 'Online',
      },
      {
        'time': '1:00 - 2:30',
        'title': 'ENG 102 English',
        'room': 'Room C1',
        'type': 'Offline',
      },
    ],
    'Thu': [],
    'Fri': [
      {
        'time': '2:00 - 3:00',
        'title': 'Chemistry',
        'room': 'Lab 1',
        'type': 'Offline',
      },
    ],
    'Sun': [],
  };

  @override
  Widget build(BuildContext context) {
    final tasks = classSchedule[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB388F5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Class Scheduler', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFB388F5)),
            onPressed: () {},
          )
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFB388F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's date: 20-2-2025 (Wednesday)",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You have ${tasks.length} class${tasks.length == 1 ? '' : 'es'} to attend today.",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sun']
                  .map((day) => GestureDetector(
                        onTap: () => setState(() => selectedDay = day),
                        child: DayButton(day: day, selected: selectedDay == day),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text("No classes scheduled.", style: TextStyle(color: Colors.white70)),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFB388F5)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(task['time'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white70)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task['title'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text("Classroom : ${task['room']}", style: const TextStyle(color: Colors.white70)),
                                    Text("Type : ${task['type']}", style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              )
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
}

class DayButton extends StatelessWidget {
  final String day;
  final bool selected;

  const DayButton({super.key, required this.day, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFB388F5) : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB388F5)),
      ),
      child: Text(
        day,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
