import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddClassPage extends StatelessWidget {
  const AddClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      appBar: AppBar(
        title:
            const Text('Add New Class', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ClassForm(buttonText: 'Add'),
      ),
    );
  }
}

class ClassForm extends StatefulWidget {
  final String buttonText;
  const ClassForm({super.key, required this.buttonText});

  @override
  State<ClassForm> createState() => _ClassFormState();
}

class _ClassFormState extends State<ClassForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classroomController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  String selectedType = 'Onsite';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> allDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  String? dropdownDay;

  void _pickTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _endTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid start and end times')),
      );
      return;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('creator', isEqualTo: currentUser.uid)
          .where('day', isEqualTo: dropdownDay)
          .get();

      bool hasConflict = false;
      for (final doc in querySnapshot.docs) {
        final existingStart = doc['startTime'] as int;
        final existingEnd = doc['endTime'] as int;

        if (startMinutes < existingEnd && endMinutes > existingStart) {
          hasConflict = true;
          break;
        }
      }

      if (hasConflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot conflicts with an existing class')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('classes').add({
        'name': _nameController.text.trim(),
        'classroom': _classroomController.text.trim(),
        'type': selectedType,
        'day': dropdownDay,
        'startTime': startMinutes,
        'endTime': endMinutes,
        'creator': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Name', _nameController, 'Enter class name'),
            const SizedBox(height: 16),
            _buildTimeField('Class Start', _startTimeController, true),
            const SizedBox(height: 16),
            _buildTimeField('Class End', _endTimeController, false),
            const SizedBox(height: 16),
            _buildDropdownType(),
            const SizedBox(height: 16),
            _buildTextField(
                'Classroom', _classroomController, 'Enter classroom number'),
            const SizedBox(height: 16),
            _buildDayDropdownSelector(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB388F5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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



  Widget _buildTextField(
      String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(hintText),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimeField(
      String label, TextEditingController controller, bool isStartTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickTime(isStartTime),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Select time'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a time';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedType,
          dropdownColor: const Color(0xFF2E2E48),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Select type'),
          iconEnabledColor: Colors.white,
          items: const [
            DropdownMenuItem(
                value: 'Onsite',
                child: Text('Onsite', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(
                value: 'Online',
                child: Text('Online', style: TextStyle(color: Colors.white))),
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

  Widget _buildDayDropdownSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Day of Week', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: dropdownDay,
          hint: const Text("Choose a day",
              style: TextStyle(color: Colors.white70)),
          dropdownColor: const Color(0xFF2E2E48),
          iconEnabledColor: Colors.white,
          decoration: _inputDecoration('Choose day'),
          items: allDays.map((day) {
            return DropdownMenuItem(
              value: day,
              child: Text(day, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              dropdownDay = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a day';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
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
    );
  }
}
