import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'course_content_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Razorpay _razorpay;
  bool isPremium = false; // local flag (you can also fetch from Firestore for real persistence)

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_R9e67H5dIpbeBV', // <-- Replace with your Razorpay Test Key
      'amount': 100, // 100 paise = ₹1
      'name': 'College Project',
      'description': 'Premium Access',
      'prefill': {'contact': '9999999999', 'email': 'test@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      isPremium = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Premium Unlocked! PaymentId: ${response.paymentId}")),
    );

    // TODO: Save premium status in Firestore for the student
    // FirebaseFirestore.instance.collection('students').doc(studentId).update({'isPremium': true});
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.code} - ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No courses available"));
          }

          final courses = snapshot.data!.docs;

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
                              ),
                            ),
                          );
                        },
                        child: const Text("View Content"),
                      ),

                      const SizedBox(height: 8),

                      isPremium
                          ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseContentPage(
                                courseId: courses[index].id,
                                courseTitle: course['title'] ?? "Course",
                                isPremium: true,
                              ),
                            ),
                          );
                        },
                        child: const Text("View Premium Content"),
                      )
                          : ElevatedButton(
                        onPressed: _openCheckout,
                        child: const Text("Add Premium (₹1)"),
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
