import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamForm extends StatefulWidget {
  final String buttonText;
  final String? examId;

  const ExamForm({super.key, required this.buttonText, this.examId});

  @override
  State<ExamForm> createState() {
    return _ExamFormState();
  }
}

class _ExamFormState extends State<ExamForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedType = 'Module1';
  
@override
void initState() {
  super.initState();
  if (widget.buttonText == 'Save' && widget.examId != null) {
    _loadExamData();
  }
}

Future<void> _loadExamData() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final examDate = (data['examDate'] as Timestamp).toDate();
      final startTime = (data['startTime'] as Timestamp).toDate();
      final endTime = (data['endTime'] as Timestamp).toDate();

      setState(() {
        _nameController.text = data['name'] ?? '';
        selectedType = data['type'] ?? 'Module1';
        _venueController.text = data['venue'] ?? '';
        _descriptionController.text = data['description'] ?? '';

        _dateController.text =
            "${examDate.day}-${examDate.month}-${examDate.year}";
        _startTimeController.text = DateFormat.jm().format(startTime);
        _endTimeController.text = DateFormat.jm().format(endTime);
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error loading exam: $e")));
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Name', _nameController),
            const SizedBox(height: 16),
            _buildDropdown('Type'),
            const SizedBox(height: 16),
            _buildDatePickerField('Date', _dateController),
            const SizedBox(height: 16),
            _buildTimePickerField('Start Time', _startTimeController),
            const SizedBox(height: 16),
            _buildTimePickerField('End Time', _endTimeController),
            const SizedBox(height: 16),
            _buildTextField('Venue', _venueController),
            const SizedBox(height: 16),
            _buildTextField('Description (Optional)', _descriptionController,
                maxLines: 5),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB388F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  widget.buttonText,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    final dateFormat = DateFormat.jm();
    final dateTime = dateFormat.parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final venue = _venueController.text.trim();
    final description = _descriptionController.text.trim();
    final dateText = _dateController.text.trim();
    final startTimeText = _startTimeController.text.trim();
    final endTimeText = _endTimeController.text.trim();

    if (name.isEmpty ||
        venue.isEmpty ||
        dateText.isEmpty ||
        startTimeText.isEmpty ||
        endTimeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("All fields except description are required.")));
      return;
    }

    try {
      final start = parseTimeOfDay(startTimeText);
      final end = parseTimeOfDay(endTimeText);

      final dateParts = dateText.split("-");
      final examDate = DateTime(int.parse(dateParts[2]),
          int.parse(dateParts[1]), int.parse(dateParts[0]));

      final startDateTime = DateTime(examDate.year, examDate.month,
          examDate.day, start.hour, start.minute);
      final endDateTime = DateTime(
          examDate.year, examDate.month, examDate.day, end.hour, end.minute);

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("End time cannot be before start time.")));
        return;
      }

      // Check for time conflicts
      final query = await FirebaseFirestore.instance
          .collection('exams')
          .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('examDate', isEqualTo: Timestamp.fromDate(examDate))
          .get();

      for (var doc in query.docs) {
        if (widget.examId != null && doc.id == widget.examId) continue;

        final docStart = (doc['startTime'] as Timestamp).toDate();
        final docEnd = (doc['endTime'] as Timestamp).toDate();

        if (startDateTime.isBefore(docEnd) && endDateTime.isAfter(docStart)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Time conflict with another exam: ${doc['name']}"),
          ));
          return;
        }
      }

      final examData = {
        'creator': FirebaseAuth.instance.currentUser!.uid,
        'name': name,
        'type': selectedType,
        'venue': venue,
        'description': description,
        'examDate': Timestamp.fromDate(examDate),
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
      };

      if (widget.buttonText == 'Save' && widget.examId != null) {
        await FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.examId)
            .update(examData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exam updated successfully.")));
        Navigator.pop(context);
      } else {
        await FirebaseFirestore.instance.collection('exams').add(examData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exam added successfully.")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2E2E48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) {
              String formattedDate =
                  "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              setState(() {
                controller.text = formattedDate;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2E2E48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              final now = DateTime.now();
              final dt = DateTime(now.year, now.month, now.day, pickedTime.hour,
                  pickedTime.minute);
              String formattedTime = DateFormat.jm().format(dt);
              setState(() {
                controller.text = formattedTime;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Pick $label',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2E2E48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedType,
          dropdownColor: const Color(0xFF2E2E48),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2E2E48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          iconEnabledColor: Colors.white,
          items: const [
            DropdownMenuItem(
                value: 'Module1',
                child: Text('Module 1', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(
                value: 'Module2',
                child: Text('Module 2', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(
                value: 'Module3',
                child: Text('Module 3', style: TextStyle(color: Colors.white))),
          ],
          onChanged: (value) {
            setState(() {
              selectedType = value!;
            });
          },
        ),
      ],
    );
  }
}
