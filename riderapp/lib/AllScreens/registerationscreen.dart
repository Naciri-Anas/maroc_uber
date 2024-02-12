import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riderapp/AllScreens/loginscreen.dart';
import 'package:riderapp/AllScreens/mainscreen.dart';
import 'package:riderapp/AllWidgets/progressDialog.dart';
import 'package:riderapp/main.dart';

class RegisterScreen extends StatelessWidget {
  static const String idScreen = "register";
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50.0,
            ),
            const Image(
              image: AssetImage("images/dd-removebg-preview.png"),
              width: 390.0,
              height: 300.0,
              alignment: Alignment.center,
            ),
            const SizedBox(
              height: 1.0,
            ),
            const Text(
              "Register As Rider",
              style: TextStyle(fontSize: 24.0, fontFamily: "bolt-semibold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    onPressed: () {
                      if (nameTextEditingController.text.length < 3) {
                        displayToastMessage(
                            "name must be atlest 3 character  ,", context);
                      } else if (!emailTextEditingController.text
                          .contains("@")) {
                        displayToastMessage(
                            "email adress is not valide ,", context);
                      } else if (phoneTextEditingController.text.isEmpty) {
                        displayToastMessage("phone is not valide ,", context);
                      } else if (passwordTextEditingController.text.length <
                          6) {
                        displayToastMessage(
                            "password must be 6 character  ,", context);
                      } else {
                        registerNewUser(context);
                      }
                    },
                    child: const SizedBox(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "bolt-semibold",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: const Text(
                "Already have an account? Login Here.",
              ),
            )
          ],
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async
   {
showDialog(context: context,
     barrierDismissible: false,
     builder: (BuildContext context) 
     {
        return  ProgressDialog(message:"Registering ,please whait..." ,);
     }
    
    
    );

    final firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
              Navigator.pop(context);
      displayToastMessage("Error ,$errMsg", context);
    }))
        .user;

    if (firebaseUser != null) //user created
    {
//save user info to database

      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      usersRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage("good your account has been created ", context);

      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
//error occured display error msg
      displayToastMessage("New user account has not been created", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}