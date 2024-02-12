import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driverapp/AllScreens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:driverapp/AllScreens/mainscreen.dart';
import 'package:driverapp/AllScreens/registerationscreen.dart';
import 'package:provider/provider.dart';
import 'package:driverapp/DataHandler/appData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: "AIzaSyCzSC2rBy8f73koSi1DMaIyEiSGvNRcdXk",
          appId: "1:1041742663675:android:6aadee04d5ba8c7d34455e",
          messagingSenderId: "1041742663675",
          projectId: "riderapp-e117d",
        ))
      : await Firebase.initializeApp();
  runApp(const MainApp());
}

DatabaseReference usersRef =
    // ignore: deprecated_member_use
    FirebaseDatabase.instance.ref().child("users");

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'driver app',
        theme: ThemeData(
          fontFamily: "bolt-semibold",
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idScreen
            : MainScreen.idScreen,
        routes: {
          RegisterScreen.idScreen: (context) => RegisterScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
        },
      ),
    );
  }
}
