import 'package:flutter/material.dart';
import 'class_form.dart';

class EditClassPage extends StatelessWidget {
  const EditClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      appBar: AppBar(
        title: const Text('Edit Class', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const ClassForm(buttonText: 'Save'),
      ),
    );
  }
}
