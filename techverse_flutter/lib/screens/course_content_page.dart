import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_player_page.dart';

class CourseContentPage extends StatelessWidget{
  final String courseId;
  final String courseTitle;
  final bool isPremium;

  const CourseContentPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.isPremium=false,
  });
  void _openPdf(String pdfUrl) async {
    final Uri uri = Uri.parse("https://docs.google.com/viewer?url=$pdfUrl");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openVideo(BuildContext context,String videoUrl) async{
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context)=>VideoPlayerPage(url:videoUrl),
      ),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(courseTitle)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').doc(courseId).snapshots(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child:CircularProgressIndicator());
          }
          if(!snapshot.hasData || !snapshot.data!.exists){
            return const Center(child: Text("No Content Available"));
          }
          final course=snapshot.data!.data() as Map<String,dynamic>;

          if((course['premium']??false)!=isPremium){
            return const Center(child: Text("This course is not Available, It is in premium mode"));
          }
          final pdfs=<Map<String,dynamic>>[];

          if (course['pdfUrls'] != null && course['pdfUrls'] is List) {
            final pdfList = course['pdfUrls'] as List<dynamic>;
            for (var pdf in pdfList) {
              if (pdf is Map<String, dynamic>) {
                pdfs.add({
                  'name': pdf['name'] ?? 'PDF',
                  'url': pdf['url'] ?? '',
                });
              }
            }
          }
          final videos=<Map<String,dynamic>>[];
          if(course['videoUrls']!=null && course['videoUrls'] is List){
            final videoList=course['videoUrls'] as List<dynamic>;
            for(var video in videoList){
              videos.add({
                'name':video['name']??'Video',
                'url':video['url']??'',
              });
            }
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if(pdfs.isNotEmpty)...[
                const Text("PDFs",
                  style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)
                ),
                ...pdfs.map(
                    (pdf)=>ListTile(
                      leading: const Icon(Icons.picture_as_pdf,color:Colors.red),
                      title: Text(pdf['name']),
                      onTap: ()=>_openPdf(pdf['url']),
                    ),
                ),
                const SizedBox(height: 20),
              ],
              if(videos.isNotEmpty)...[
                const Text("Videos:",
                  style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)
                ),
                ...videos.map(
                    (video)=>ListTile(
                      leading: const Icon(Icons.video_library,color:Colors.blueAccent),
                      title: Text(video['name']),
                      onTap: ()=>_openVideo(context,video['url']),
                    ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}