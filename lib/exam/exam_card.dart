import 'package:flutter/material.dart';

class ExamCard extends StatelessWidget {
  final String examType;
  final String subject;
  final String venue;
  final String date;
  final String time;

  const ExamCard({
    Key? key,
    required this.examType,
    required this.subject,
    required this.venue,
    required this.date,
    required this.time,
  }) : super(key: key);

 void _showExamDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Exam Details",
                  
                  style: TextStyle(color: const Color(0xFFB388F5),fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: const Color(0xFFB388F5)),
                  iconSize: 17,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
             Divider(
              color: const Color(0xFFB388F5),
              thickness: 2,
              
            ),
          ],
        ),
        
        
        content: Column(
          
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Text(subject, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _detailText("Type : ", examType),
            _detailText("Date : ", date),
            _detailText("Time : ", time),
            _detailText("Venue : ", venue),
            const SizedBox(height: 12),
            const Text(
              "Description : ",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Chapter 1\nExercise 2,3\nChapter 10 page number 45",
              style: TextStyle(color: Colors.white70),
            ),
        
          ],
        ),

        actions: [
          Column(
            children: [
              Divider(
              color: const Color(0xFFB388F5),
              thickness: 2,
              
            ),
            SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                
                
                
                children: [
                  TextButton(
                    
                    style: TextButton.styleFrom(
                      // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      fixedSize:  const Size(90, 20),
                      backgroundColor:  const Color(0xFFB388F5), 
                      ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_exam');
                    },
                    child: const Text("Edit", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.white),),
                    
                  ),
                  const SizedBox(width: 12.0),
                  TextButton(
                    style: TextButton.styleFrom(
                      // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      fixedSize:  const Size(90, 20),
                      backgroundColor: const Color(0xFFB388F5),
                   ),
                    onPressed: () {},
                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all( 4),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showExamDetailsDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          color: const Color(0xFF2E2E48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        examType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Venue: $venue",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Time: $time",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
