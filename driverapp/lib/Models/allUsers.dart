import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;

  Users({
    this.id,
    this.email,
    this.name,
    this.phone,
  });
  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    
  if (dataSnapshot.value is Map<String, dynamic>) {
    // Cast dataSnapshot.value to Map<String, dynamic>
    Map<String, dynamic> dataMap = dataSnapshot.value as Map<String, dynamic>;

    // Access properties using square brackets
    email = dataMap["email"];
    name = dataMap["name"];
    phone = dataMap["phone"];
  } else {
    
    
  }
  }
}
