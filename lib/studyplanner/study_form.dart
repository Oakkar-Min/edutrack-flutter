// import 'package:flutter/material.dart';

// class TaskForm extends StatefulWidget {
//   final String buttonText;
//   const TaskForm({super.key, required this.buttonText});

//   @override
//   State<TaskForm> createState() => _TaskFormState();
// }

// class _TaskFormState extends State<TaskForm> {
//   final TextEditingController _titleController = TextEditingController(text: 'Read Linear Algebra');
//   final TextEditingController _descriptionController = TextEditingController(text: 'Chapter 3 Exercises');
//   String selectedStatus = 'Pending';

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildTextField('Title', _titleController),
//             const SizedBox(height: 16),
//             _buildDropdown('Status'),
//             const SizedBox(height: 16),
//             _buildTextField('Description (Optional)', _descriptionController, maxLines: 5),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFB388F5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: _handleSubmit,
//                 child: Text(
//                   widget.buttonText,
//                   style: const TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleSubmit() {
//     final creationDate = DateTime.now();
//     print("Title: ${_titleController.text}");
//     print("Status: $selectedStatus");
//     print("Description: ${_descriptionController.text}");
//     print("Created at: $creationDate");

//     if (widget.buttonText == 'Save') {
//       Navigator.pop(context); // Update route as needed
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white)),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: const Color(0xFF2E2E48),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown(String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white)),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: selectedStatus,
//           dropdownColor: const Color(0xFF2E2E48),
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: const Color(0xFF2E2E48),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//           ),
//           iconEnabledColor: Colors.white,
//           items: const [

//             DropdownMenuItem(value: 'Pending', child: Text('Pending', style: TextStyle(color: Colors.white))),
//             DropdownMenuItem(value: 'Completed', child: Text('Completed', style: TextStyle(color: Colors.white))),
//           ],
//           onChanged: (value) {
//             setState(() {
//               selectedStatus = value!;
//             });
//           },
//         ),
//       ],
//     );
//   }
// }
