import 'package:flutter/material.dart';

class ClassForm extends StatefulWidget {
  final String buttonText;
  const ClassForm({super.key, required this.buttonText});

  @override
  State<ClassForm> createState() => _ClassFormState();
}

class _ClassFormState extends State<ClassForm> {
  final _nameController = TextEditingController(text: 'CSC 304 Linear Algebra');
  final _classroomController = TextEditingController(text: '2306');
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  String selectedType = 'Onsite';

  final List<String> allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String? dropdownDay;

  void _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  void _handleSubmit() {
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select class start and end time')));
      return;
    }

    print("Selected Day: $dropdownDay");

    if (widget.buttonText == 'Save') {
      print("Save Clicked");
    } else {
      print("Add Clicked");
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Name', _nameController),
            const SizedBox(height: 16),
            _buildTimeField('Class Start', _startTimeController),
            const SizedBox(height: 16),
            _buildTimeField('Class End', _endTimeController),
            const SizedBox(height: 16),
            _buildDropdownType(),
            const SizedBox(height: 16),
            _buildTextField('Classroom', _classroomController),
            const SizedBox(height: 16),
            _buildDayDropdownSelector(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB388F5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickTime(controller),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
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
          decoration: _inputDecoration(),
          iconEnabledColor: Colors.white,
          items: const [
            DropdownMenuItem(value: 'Onsite', child: Text('Onsite', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Online', child: Text('Online', style: TextStyle(color: Colors.white))),
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
          hint: const Text("Choose a day", style: TextStyle(color: Colors.white70)),
          dropdownColor: const Color(0xFF2E2E48),
          iconEnabledColor: Colors.white,
          decoration: _inputDecoration(),
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
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
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
