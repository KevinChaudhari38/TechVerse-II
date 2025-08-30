import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInbuiltCourse extends StatefulWidget {
  final bool isPremium;
  const AddInbuiltCourse({super.key,this.isPremium=false});

  @override
  _AddInbuiltCourseState createState() => _AddInbuiltCourseState();
}

class _AddInbuiltCourseState extends State<AddInbuiltCourse> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();


  Uint8List? imageBytes;
  Uint8List? pdfBytes;
  Uint8List? videoBytes;
  String? pdfName;
  String? videoName;

  bool _isLoading = false;

  // Cloudinary config
  final String cloudinaryCloudName = 'dpntbppvp';
  final String cloudinaryUploadPreset = 'flutter_unsigned_preset';

  Future<void> _pickImage() async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        imageBytes = pickedFile.files.single.bytes;
      });
    }
  }

  Future<void> _pickFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (pickedFile != null) {
      setState(() {
        pdfBytes = pickedFile.files.single.bytes;
        pdfName = pickedFile.files.single.name;
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await FilePicker.platform.pickFiles(type: FileType.video);
    if (pickedVideo != null) {
      setState(() {
        videoBytes = pickedVideo.files.single.bytes;
        videoName = pickedVideo.files.single.name;
      });
    }
  }

  Future<String?> uploadFileToCloudinary({
    Uint8List? bytes,
    required String resourceType, // "image", "raw", "video"
    String fileName = "file",
  }) async {
    if (bytes == null) return null;

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$resourceType/upload');
    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = cloudinaryUploadPreset;

    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName.split('.').first));

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final respStr = await streamedResponse.stream.bytesToString();
      final Map<String, dynamic> respData = json.decode(respStr);
      return respData['secure_url'] as String?;
    } else {
      print('Cloudinary upload failed with status: ${streamedResponse.statusCode}');
      return null;
    }
  }

  Future<void> _saveCourse() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title, description and image are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = await uploadFileToCloudinary(
        bytes: imageBytes,
        resourceType: 'image',
        fileName: 'course_image.png',
      );

      String? pdfUrl = await uploadFileToCloudinary(
        bytes: pdfBytes,
        resourceType: 'raw',
        fileName: pdfName ?? 'file',
      );

      String? videoUrl = await uploadFileToCloudinary(
        bytes: videoBytes,
        resourceType: 'video',
        fileName: videoName ?? 'video.mp4',
      );

      await FirebaseFirestore.instance.collection('courses').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'pdfUrls': pdfUrl != null ? [{'name': pdfName ?? 'UploadedFile', 'url': pdfUrl,}] : [],
        'videoUrls': videoUrl != null ? [{'name': videoName?? 'UploadedVideo','url':videoUrl,}]:[],

        'premium': widget.isPremium,
        'createdAt': FieldValue.serverTimestamp(),
      });

      titleController.clear();
      descriptionController.clear();

      setState(() {
        imageBytes = null;
        pdfBytes = null;
        videoBytes = null;
        pdfName = null;
        videoName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isPremium?'Add Premium Course':'Add Inbuilt Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Course Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text(imageBytes == null ? 'Pick Image (Required)' : 'Image Selected'),
            ),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(pdfBytes == null ? 'Pick PDF (Optional)' : 'PDF Selected'),
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text(videoBytes == null ? 'Pick Video (Optional)' : 'Video Selected'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveCourse,
              child: const Text('Save Course'),
            ),
          ],
        ),
      ),
    );
  }
}
