import 'package:flutter/material.dart';
import 'package:edu_track_project/widgets/schedule_card.dart';

class ClassSchedulePage extends StatelessWidget {
  const ClassSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        title: Text('Class Schedule', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // actions: [
        //   Icon(Icons.refresh, color: Colors.white),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start ,
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
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
                              fontWeight: FontWeight.bold),
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
               ),
            
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                dayButton("Sat"),
                dayButton("Mon"),
                dayButton("Tue"),
                dayButton("Wed", isSelected: true),
                dayButton("Thu"),
                dayButton("Fri"),
                dayButton("Sun"),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 5,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: 5, // 5 dummy schedules
                itemBuilder: (context, index) {
                  return ScheduleCard(
                    startTime: "8:00",
                    endTime: "12:00",
                    subject: "CSC 304 Linear Algebra",
                    room: "CB2312",
                    type: index % 2 == 0 ? "Online" : "Onsite", 
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dayButton(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple : const Color(0xFF2E2E48),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
