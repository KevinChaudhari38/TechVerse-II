import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget{
  @override
  _RegisterScreenState createState()=>_RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen>{
  final _auth=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  String selectedRole='Student';

  void register() async{
    try{
      UserCredential user=await _auth.createUserWithEmailAndPassword(
        email:emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await _firestore.collection('users').doc(user.user!.uid).set({
        'email': user.user!.email,
        'role' : selectedRole,
        'uid': user.user!.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registred successfully as $selectedRole")));
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed")));
    }

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController,decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController,decoration: InputDecoration(labelText: "Password")),
            DropdownButton<String>(
              value:selectedRole,
              items: ["Student","Teacher"].map((role)=>DropdownMenuItem(value: role,child: Text(role))).toList(),
              onChanged: (val)=> setState(()=>selectedRole=val!),
            ),
            ElevatedButton(onPressed: register,child: Text("Register"))

          ],
        ),
      ),
    );
  }
}