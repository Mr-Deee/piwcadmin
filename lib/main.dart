import 'package:flutter/material.dart';
import 'package:piwcadmin/pages/signin.dart';
import 'package:piwcadmin/pages/signup.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/generateqr.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
DatabaseReference clients = FirebaseDatabase.instance.ref().child("Clients");
DatabaseReference Admin = FirebaseDatabase.instance.ref().child("Admin");
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIWCADMIN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  Signin(),

    initialRoute: FirebaseAuth.instance.currentUser == null
    ? "/login"
        :"/generateqr",
    // : Doctorspage.idScreen,

    routes: {
    "/login": (context) => Signin(),
    "/generateqr":(context)=>AttendanceQRCodeScreen(),
    "/registration": (context) => SignUp(),



  }

    );
  }
}



