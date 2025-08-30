import 'package:flutter/material.dart';
import 'add_pdf.dart';
import 'add_video.dart';
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Dashboard")),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children:[
            ElevatedButton(
              child: const Text("Add PDF"),
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPdf()),
              );
             },
            ),
            const SizedBox(height:20),
            ElevatedButton(
              child: const Text("Add Video"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddVideo()),
                );
              },
            ),
          ]


        ),

      ),
    );
  }
}
