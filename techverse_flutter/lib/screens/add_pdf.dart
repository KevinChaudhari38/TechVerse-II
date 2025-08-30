import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class AddPdf extends StatefulWidget {
  const AddPdf({super.key});

  @override
  AddPdfState createState() => AddPdfState();
}

class AddPdfState extends State<AddPdf> {
  String? selectedSubject;
  bool _isLoading = false;

  final String cloudinaryName = 'dpntbppvp';
  final String cloudinaryUploadPreset = 'flutter_unsigned_preset';

  Future<List<String>> _fetchSubjects() async {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();
    return snapshot.docs.map((doc) => doc['title'].toString()).toList();
  }

  Future<String?> _uploadToCloudinary({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryName/raw/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: 'file'));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resString = await response.stream.bytesToString();
      return jsonDecode(resString)['secure_url'];
    }
    return null;
  }

  Future<void> _uploadPdfForSubject() async {
    if (selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a subject")),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final fileName = result.files.single.name;
      final fileBytes = result.files.single.bytes;

      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to read file bytes")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final fileUrl = await _uploadToCloudinary(fileBytes: fileBytes, fileName: fileName);

      if (fileUrl != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('courses')
            .where('title', isEqualTo: selectedSubject)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final docId = snapshot.docs.first.id;
          await FirebaseFirestore.instance.collection('courses').doc(docId).update({
            'pdfUrls': FieldValue.arrayUnion([
              {'name': fileName, 'url': fileUrl}
            ]),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF uploaded successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Course not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cloudinary upload failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add PDF")),
      body: FutureBuilder<List<String>>(
        future: _fetchSubjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final subjects = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  hint: const Text("Select Subject"),
                  onChanged: (value) => setState(() => selectedSubject = value),
                  items: subjects
                      .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                      .toList(),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload PDF"),
                  onPressed: _uploadPdfForSubject,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
