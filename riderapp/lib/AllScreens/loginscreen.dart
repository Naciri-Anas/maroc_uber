
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riderapp/AllScreens/mainscreen.dart';
import 'package:riderapp/AllScreens/registerationscreen.dart';
import 'package:riderapp/AllWidgets/progressDialog.dart';
import 'package:riderapp/main.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "Login";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  LoginScreen({super.key});

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
              "Login As Rider",
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
                    controller : passwordTextEditingController,
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
                    onPressed: () 
                    {
                      if (!emailTextEditingController.text
                          .contains("@")) {
                        displayToastMessage(
                            "email adress is not valide ,", context);
                      }
                      else if (passwordTextEditingController.text.isEmpty)
                      {
                        displayToastMessage(
                            "password is mandatory  ,", context);
                      } 
                      else 
                      {
                         loginAndAuthenticateUser(context);
                      }
                  
                    },
                    child: const SizedBox(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Login",
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
                    context, RegisterScreen.idScreen, (route) => false);
              },
              child: const Text(
                "You don't have an account? Register Here.",
              ),
            )
          ],
        ),
      ),
    );
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   void loginAndAuthenticateUser(BuildContext context) async
  {

    showDialog(context: context,
     barrierDismissible: false,
     builder: (BuildContext context) 
     {
        return  ProgressDialog(message:"authenticationg ,please whait..." ,);
     }
    
    
    );

final firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
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

     
     usersRef.child(firebaseUser.uid).onValue.listen((event) {
  if (event.snapshot.value != null) {
    Navigator.pushNamedAndRemoveUntil(
      context, MainScreen.idScreen, (route) => false);
    displayToastMessage("You are logged in now", context);
  } else {
    Navigator.pop(context);
    _firebaseAuth.signOut();
    displayToastMessage("No record exists. Please create a new account", context);
  }
}, onError: (error) {
  print("Error: $error");
});


    
    } else {
      Navigator.pop(context);
//error occured display error msg
      displayToastMessage("Error o cant be", context);
    }


  }
}
