import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/progressdialog.dart';
class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: "Resetting Password, Please wait.",
        );
      },
    );

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      // Password reset email sent successfully
      print("Password reset email sent successfully");

      // Close the dialog
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      // You can show a success message or navigate to another screen here
      // For example, show a snackbar:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset email sent successfully"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle errors, such as invalid email or user not found
      print("Error sending password reset email: $e");

      // Close the dialog
      Navigator.of(context).pop();

      // Show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Error sending password reset email: $e"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(

                  border: OutlineInputBorder(),
                  labelText: "Email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(

              onPressed:(){
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return ProgressDialog(
                        message: "Resetting Password ,Please wait.",
                      );
                    });

                _resetPassword();
                },
              child: Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}