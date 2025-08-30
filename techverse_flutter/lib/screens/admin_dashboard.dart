import 'package:flutter/material.dart';
import 'add_inbuilt_course.dart';
import 'manage_courses.dart';
import 'add_pdf.dart';
import 'user_list_screen.dart';
import 'add_video.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Add Inbuilt Course"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddInbuiltCourse()));
              },
            ),
            const SizedBox(height:20),
            ElevatedButton(
              child: const Text("Manage Courses"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ManageCourses()));
              },
            ),
            const SizedBox(height:20),
            ElevatedButton(
              child: const Text("Add pdf"),
              onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (_)=>const AddPdf())
                );
              }
            ),
            const SizedBox(height:20),

            ElevatedButton(
                child: const Text("Add Video"),
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_)=>const AddVideo())
                  );
                }
            ),
            const SizedBox(height:20),

            ElevatedButton(
              child: const Text("Add Premium Course"),
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (_)=>const AddInbuiltCourse(isPremium:true)));
              }
            ),
            const SizedBox(height:20),
            ElevatedButton(
              child: const Text("View Students"),
              onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder:(_)=>const UserListScreen(role:"Student")),
                );
              },
            ),
            const SizedBox(height:20),
            ElevatedButton(
              child: const Text("View Teachers"),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_)=>const UserListScreen(role:"Teacher")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
