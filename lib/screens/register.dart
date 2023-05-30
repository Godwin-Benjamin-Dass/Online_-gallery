import 'package:fire_gallery/screens/gallery_Screen.dart';
import 'package:fire_gallery/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class register extends StatelessWidget {
  register({Key? key}) : super(key: key);
  TextEditingController _Emailcontroller = TextEditingController();
  TextEditingController _Passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.redAccent[200],
        appBar: AppBar(
          title: Text('Sign in'),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Text(
                    'Register Account',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.redAccent[200],
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 75, left: 8),
                  child: TextFormField(
                    controller: _Emailcontroller,
                    decoration: InputDecoration(
                        labelText: 'register',
                        prefixIcon: Icon(
                          Icons.account_box_rounded,
                          color: Colors.redAccent[200],
                          size: 50,
                        ),
                        hintText: 'user@email.com'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, right: 8, left: 8),
                  child: TextFormField(
                    controller: _Passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.redAccent[200],
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 30.0, left: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _Emailcontroller.text.toString().trim(),
                              password: _Passwordcontroller.text)
                          .then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Gallery_Screen()));
                        pref.setString("email", _Emailcontroller.text.trim());
                      }).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("ERROR ${error.toString()}"),
                          behavior: SnackBarBehavior.floating,
                        ));
                        print("ERROR ${error.toString()}");
                      });
                    },
                    child: Text('   register   '),
                    style: ButtonStyle(),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('have an account?'))
              ],
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            // color: Colors.white,
          ),
        ));
  }
}
