import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_content_page.dart';

class CourseListPage extends StatelessWidget {
  final bool isPremium;

  const CourseListPage({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isPremium ? "Premium Courses" : "Courses"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No courses available"));
          }

          final allCourses = snapshot.data!.docs;

          // filter based on premium flag
          final courses = allCourses.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final premiumFlag = data['isPremium'] == true;
            if (isPremium) {
              return true; // show all courses (normal + premium)
            } else {
              return !premiumFlag; // show only normal courses
            }
          }).toList();

          if (courses.isEmpty) {
            return const Center(child: Text("No courses available"));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (course['imageUrl'] != null &&
                          course['imageUrl'].toString().isNotEmpty)
                        Image.network(
                          course['imageUrl'],
                          height: 120,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        course['title'] ?? "No Title",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(course['description'] ?? "No Description"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseContentPage(
                                courseId: courses[index].id,
                                courseTitle: course['title'] ?? "Course",
                                isPremium: course['isPremium'] == true,
                              ),
                            ),
                          );
                        },
                        child: const Text("View Content"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
