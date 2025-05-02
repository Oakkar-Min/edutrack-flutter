import 'package:flutter/material.dart';

class ExamForm extends StatefulWidget {
  final String buttonText;
  const ExamForm({super.key, required this.buttonText});

  @override
  State<ExamForm> createState() {
    return _ExamFormState();
  }
}

class _ExamFormState extends State<ExamForm> {
  final TextEditingController _nameController = TextEditingController(text: 'CSC 304 Linear Algebra');
  final TextEditingController _dateController = TextEditingController(text: '12-2-2025');
  final TextEditingController _timeController = TextEditingController(text: '01:30 AM');
  final TextEditingController _venueController = TextEditingController(text: 'CB2308');
  final TextEditingController _descriptionController = TextEditingController(text: 'Chapter 1...\nSome graph...\nChapter 3 calculation 3...');
  
  String selectedType = 'Module1';

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
            _buildTimePickerField('Time', _timeController),
            const SizedBox(height: 16),
            _buildTextField('Venue', _venueController),
            const SizedBox(height: 16),
            _buildTextField('Description (Optional)', _descriptionController, maxLines: 5),
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
                onPressed: () {
                   _handleSubmit();
                },
                child: Text(
                  
                  widget.buttonText,
                  style: const TextStyle(fontSize: 18,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if(widget.buttonText == 'Save'){

    print("Save Clicked");
     Navigator.pushNamed(context, '/exams') ;
    }else if(widget.buttonText == 'Add'){

      print("Add Clicked");
      Navigator.pop(context);
    }
   
   
  }


  

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
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
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) {
              String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              setState(() {
                controller.text = formattedDate;
              });
            }
          },
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
              final dt = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
              String formattedTime = TimeOfDay.fromDateTime(dt).format(context);
              setState(() {
                controller.text = formattedTime;
              });
            }
          },
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
            DropdownMenuItem(value: 'Module1', child: Text('Module 1', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Module2', child: Text('Module 2', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Module3', child: Text('Module 3', style: TextStyle(color: Colors.white))),
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
