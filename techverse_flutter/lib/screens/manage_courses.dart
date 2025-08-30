import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCourses extends StatelessWidget {
  const ManageCourses({super.key});

  void deleteCourse(String id) {
    FirebaseFirestore.instance.collection('courses').doc(id).delete();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Courses")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                title: Text(course['title']),
                subtitle: Text(course['description']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteCourse(course.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
