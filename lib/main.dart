import 'package:fire_gallery/firebase_options.dart';
import 'package:fire_gallery/screens/gallery_Screen.dart';
import 'package:fire_gallery/screens/login.dart';
import 'package:fire_gallery/screens/upload_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences pref = await SharedPreferences.getInstance();
  var email = pref.getString('email');
  runApp(GetMaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: email == null ? login() : Gallery_Screen()));
}
