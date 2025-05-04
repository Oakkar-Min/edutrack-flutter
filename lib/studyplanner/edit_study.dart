import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    // Fetch existing task data when the page is initialized
    _fetchTaskData();
  }

  Future<void> _fetchTaskData() async {
    try {
      DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('studyTasks')
          .doc(widget.taskId)
          .get();

      if (taskSnapshot.exists) {
        var taskData = taskSnapshot.data() as Map<String, dynamic>;
        _titleController.text = taskData['title'];
        _descriptionController.text = taskData['description'] ?? '';
        selectedStatus = taskData['status'] ?? 'Pending';
        setState(() {}); // Update the UI after fetching data
      }
    } catch (e) {
      print("Error fetching task data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load task data')),
      );
    }
  }

  void _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final updatedData = {
      'title': title,
      'description': description,
      'status': selectedStatus,
    };

    try {
      await FirebaseFirestore.instance.collection('studyTasks').doc(widget.taskId).update(updatedData);
      Navigator.pop(context); // Close the edit page after update
    } catch (e) {
      print("Error updating task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update task')),
      );
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
          "Edit Task",
          style: TextStyle(color: Color(0xFFB388F5)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Title', _titleController, hintText: 'Enter task title'),
              const SizedBox(height: 16),
              _buildDropdown('Status'),
              const SizedBox(height: 16),
              _buildTextField('Description (Optional)', _descriptionController, maxLines: 5, hintText: 'Enter task description'),
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
                  child: const Text(
                    "Update Task",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String? hintText}) {
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
          value: selectedStatus,
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
              value: 'Pending',
              child: Text('Pending', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'Completed',
              child: Text('Completed', style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedStatus = value!;
            });
          },
        ),
      ],
    );
  }
}
