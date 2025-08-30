import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  final _auth = FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  void login() async{
    try{
      UserCredential user=await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      DocumentSnapshot userData= await _firestore.collection('users').doc(user.user!.uid).get();
      if (!userData.exists) {
        throw Exception("User document not found in Firestore.");
      }

      final data = userData.data() as Map<String, dynamic>;

      if (!data.containsKey('role')) {
        throw Exception("User document missing 'role' field.");
      }
      String role=userData['role'];
      emailController.clear();
      passwordController.clear();
      if(role=='Student'){
        Navigator.push(context,MaterialPageRoute(builder:(_)=>const StudentDashboard()));

      }else if(role=='Teacher'){
        Navigator.push(context,MaterialPageRoute(builder:(_)=>TeacherDashboard()));
      }else if (role == 'Admin') {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()));
      }
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed")));
      passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context){
    print("Rendering LoginScreen");
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController,decoration:InputDecoration(labelText:"Email")),
            TextField(controller: passwordController,decoration:InputDecoration(labelText:"Password"),obscureText: true),
            ElevatedButton(onPressed: login,child: Text("Login")),
            TextButton(onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (_)=> RegisterScreen()));

            }, child: Text("Register Here")),
            TextButton(
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (context){
                    final resetEmailController=TextEditingController();
                    return AlertDialog(
                      title: Text("Reset Password"),
                      content: TextField(
                        controller: resetEmailController,
                        decoration: InputDecoration(
                          labelText: "Enter Your Email",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async{
                            try{
                              await _auth.sendPasswordResetEmail(
                                email:resetEmailController.text.trim(),
                              );
                            Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Password reset email sent")),
                            );
                            }
                            catch(e){
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error ; ${e.toString()}")),
                            );
                            }
                          },
                          child: Text("Send"),
                        ),
                        TextButton(
                          onPressed:()=>Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Forgot Password?"),
            ),

          ],
        ),
      ),
    );
  }
}




