import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:piwcadmin/pages/signin.dart';


import '../main.dart';
import '../widgets/behavior.dart';
import '../widgets/progressdialog.dart';

class registration extends StatefulWidget {
  static const String idScreen = "registration";
  const registration({Key? key}) : super(key: key);

  @override
  State<registration> createState() => _registrationState();
}
User ?firebaseUser;
User? currentfirebaseUser;
class _registrationState extends State<registration> {

  TextEditingController email = new TextEditingController();
  TextEditingController fname = new TextEditingController();
  TextEditingController lname = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  String? _email, _password, _firstName,_lastname, _mobileNumber;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ))!;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  child: Image.asset(
                    'assets/images/background_image.jpg',
                    // #Image Url: https://unsplash.com/photos/bOBM8CB4ZC4
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(),
                      ),
                      Expanded(
                        flex: 7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaY: 100, sigmaX: 70),
                            child: SizedBox(
                              width: size.width * .96,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: size.width * .1,
                                        bottom: size.width * .1,
                                      ),
                                      child: SizedBox(
                                        height: 70,
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          // #Image Url: https://unsplash.com/photos/bOBM8CB4ZC4
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),

                                    Text("ADMIN SIGNUP",style: TextStyle(color: Colors.white,fontSize: 20),),
                                    //Username

                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: size.width / 8,
                                            width: size.width /2.4,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(right: size.width / 30),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.9),
                                              ),
                                              controller: fname,
                                              onChanged: (value){
                                                _firstName = value;
                                              },
                                              // obscureText: isPassword,
                                              // keyboardType: isEmail ? TextInputType.name : TextInputType.text,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.account_circle_outlined,
                                                  color: Colors.white.withOpacity(.8),
                                                ),
                                                border: InputBorder.none,
                                                hintMaxLines: 1,
                                                hintText:'First Name',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: size.width / 8,
                                            width: size.width / 2.4,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(right: size.width / 30),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.9),
                                              ),
                                              controller: lname,
                                              onChanged: (value){
                                                _lastname = value;
                                              },
                                              // obscureText: isPassword,
                                              // keyboardType: isEmail ? TextInputType.name : TextInputType.text,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.account_circle_outlined,
                                                  color: Colors.white.withOpacity(.8),
                                                ),
                                                border: InputBorder.none,
                                                hintMaxLines: 1,
                                                hintText:'Last Name',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),


                                    //email
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: size.width / 8,
                                            width: size.width / 2.4,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                right: size.width / 30),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.9),
                                              ),
                                              controller: email,
                                              onChanged: (value){
                                                _email = value;
                                              },
                                              // obscureText: isPassword,
                                              keyboardType:  TextInputType.emailAddress ,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.email,
                                                  color: Colors.white.withOpacity(.8),
                                                ),
                                                border: InputBorder.none,
                                                hintMaxLines: 1,
                                                hintText: 'Email...',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: size.width / 8,
                                            width: size.width / 2.4,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                right: size.width / 30),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.9),
                                              ),
                                              controller: phone,
                                              onChanged: (value){
                                                _mobileNumber = value;
                                              },

                                              keyboardType:  TextInputType.phone ,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.phone,
                                                  color: Colors.white.withOpacity(.8),
                                                ),
                                                border: InputBorder.none,
                                                hintMaxLines: 1,
                                                hintText: 'Phone Number...',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Date of Birth
                                    Row(
                                      children: [

                                        //date
                                        InkWell(
                                          onTap: () {
                                            _selectDate(context);
                                          },
                                          child: Container(
                                            height: size.width / 8,
                                            width: size.width / 2.4,
                                            alignment: Alignment.center,
                                            padding:
                                            EdgeInsets.only(right: size.width / 30),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: selectedDate != null
                                                ? Text(
                                              "${selectedDate!.toLocal()}".split(' ')[0],
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.9),
                                              ),
                                            )
                                                : Text(
                                              "Select Date of Birth",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.5),
                                              ),
                                            ),
                                          ),
                                        ),

                                        //pass
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: size.width / 8,
                                            width: size.width / 2.1,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                right: size.width / 30),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(.9),
                                              ),
                                              controller: password,
                                              obscureText: true,
                                              onChanged: (value){
                                                _password=value;
                                              },
                                              // keyboardType: isPassword ? TextInputType.name : TextInputType.text,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.password,
                                                  color: Colors.white.withOpacity(.8),
                                                ),
                                                border: InputBorder.none,
                                                hintMaxLines: 1,
                                                hintText: 'Password...',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),





                                    SizedBox(height: size.width * .1),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        registerInfirestore(context);
                                        registerNewUser(context);
                                        HapticFeedback.lightImpact();

                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          bottom: size.width * .05,
                                        ),
                                        height: size.width / 8,
                                        width: size.width / 1.25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Sign-up',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering,Please wait.....",
          );
        });


    firebaseUser = (await _firebaseAuth
        .createUserWithEmailAndPassword(
        email: email.text,
        password: password.text)
        .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) // user created

        {
      //save use into to database
      await firebaseUser?.sendEmailVerification();
      Map userDataMap = {
        "firstName": fname.text.trim(),
        "lastName": lname.text.trim(),
        "email": email.text.trim(),
        "fullName":fname.text.trim() + lname.text.trim(),
        "phone": phone.text.trim(),
        "Password": password.text.trim(),
        'Date Of Birth': selectedDate!.toLocal().toString().split(' ')[0],
        // "Dob":birthDate,
        // "Gender":Gender,
      };
      clients.child(firebaseUser!.uid).set(userDataMap);
      // Admin.child(firebaseUser!.uid).set(userDataMap);

      currentfirebaseUser = firebaseUser;
      registerInfirestore(context);
      displayToast("Congratulation, your account has been created", context);
      displayToast("A verification has been sent to your mail", context);


      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Signin()),
              (Route<dynamic> route) => false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return Signin();
        }),
      );
      // Navigator.pop(context);
      //error occured - display error
      displayToast("user has not been created", context);
    }
  }

  Future<void> registerInfirestore(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user!=null) {
      FirebaseFirestore.instance.collection('Members').doc(user.uid).set({
        'firstName': _firstName,
        'lastName': _lastname,
        'MobileNumber': _mobileNumber,
        'fullName':_firstName! +  _lastname!,
        'Email': _email,
        'Password':_password,
        // 'Gender': Gender,
        // 'Date Of Birth': birthDate,
      });
    }
    print("Registered");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return SignInScreen();
    //   }),
    // );


  }

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}