import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAssignmentPage extends StatefulWidget {
  final String assignmentId;
  final Map<String, dynamic> assignmentData;

  const EditAssignmentPage({
    Key? key,
    required this.assignmentId,
    required this.assignmentData,
  }) : super(key: key);

  @override
  State<EditAssignmentPage> createState() => _EditAssignmentPageState();
}

class _EditAssignmentPageState extends State<EditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignmentData['title']);
    _descriptionController = TextEditingController(text: widget.assignmentData['description']);
    _linkController = TextEditingController(text: widget.assignmentData['link']);
    Timestamp dueTimestamp = widget.assignmentData['dueDate'];
    _selectedDate = dueTimestamp.toDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  String _calculatePriority(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference <= 3) {
      return 'High';
    } else if (difference <= 7) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedAssignment = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dueDate': _selectedDate,
        'link': _linkController.text.trim(),
        'priority': _calculatePriority(_selectedDate),
        // status and createdAt remain unchanged
      };

      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentId)
          .update(updatedAssignment);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Assignment",
          style: TextStyle(color: Color(0xFFB388F5)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Assignment Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB388F5)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                ),

                const SizedBox(height: 20),

                // Due Date
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text('Due Date', style: TextStyle(color: Colors.white70)),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: Color(0xFFB388F5),
                                          onPrimary: Colors.white,
                                          surface: Color(0xFF2E2E48),
                                          onSurface: Colors.white,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate;
                                  });
                                }
                              },
                              child: const Text('SELECT DATE', style: TextStyle(color: Color(0xFFB388F5))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Priority display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E48),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Text('Priority:', style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 8),
                      Text(
                        _calculatePriority(_selectedDate),
                        style: TextStyle(
                          color: _calculatePriority(_selectedDate) == 'High'
                              ? Colors.red
                              : _calculatePriority(_selectedDate) == 'Medium'
                                  ? Colors.orange
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB388F5)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Link
                TextFormField(
                  controller: _linkController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Link (Optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'e.g., https://example.com',
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB388F5)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB388F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'UPDATE ASSIGNMENT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
