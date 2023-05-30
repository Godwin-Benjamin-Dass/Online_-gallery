import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fire_gallery/screens/login.dart';
import 'package:fire_gallery/screens/upload_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class Gallery_Screen extends StatefulWidget {
  const Gallery_Screen({super.key});

  @override
  State<Gallery_Screen> createState() => _Gallery_ScreenState();
}

class _Gallery_ScreenState extends State<Gallery_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Images",
          style: TextStyle(color: Colors.deepOrange),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Upload_Screen()));
                },
                icon: Icon(Icons.add, color: Colors.deepOrange)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.remove("email");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => login()));
                  });
                },
                icon: Icon(Icons.power_settings_new_rounded,
                    color: Colors.deepOrange)),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("imageUrls")
            .orderBy('time')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ));
          } else {
            return Container(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 1200 ? 5 : 3),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot x = snapshot.data!.docs[index];
                  if (x['user'] == FirebaseAuth.instance.currentUser?.email) {
                    return GestureDetector(
                      child: Container(
                          margin: EdgeInsets.all(3),
                          child: CachedNetworkImage(imageUrl: x['url'])),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(img: x['url'])));
                        // DetailScreen(img: x['url']);
                      },
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                                ClipboardData(text: x['url']))
                                            .then((value) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                      "Link have been copied")));
                                        });
                                        // copied successfully
                                      },
                                      child: Text('copy link')),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        String url = x['url'];
                                        // final tempDir=await getTe
                                        // await Dio().download(x['url'], savePath)
                                        await GallerySaver.saveImage(url,
                                                albumName: "Fire Gallery")
                                            .then((value) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                      "Image saved to gallery")));
                                        });
                                      },
                                      child: Text('Download')),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      child: Text('Delete'),
                                      onPressed: () {
                                        final storageRef =
                                            FirebaseStorage.instance.ref();
                                        final docUser = FirebaseFirestore
                                            .instance
                                            .collection("imageUrls")
                                            .doc(x['id']);
                                        final desertRef = storageRef
                                            .child("images/" + x['ref']);
                                        desertRef.delete().then((value) {
                                          docUser.delete();
                                          Navigator.of(context).pop();
                                        });

                                        // docUser.delete().then((value) async {
                                        //   await desertRef.delete();
                                        //   Navigator.of(context).pop();
                                        // });
                                      }),
                                ],
                              ));
                            });
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  var img;
  DetailScreen({this.img});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(img),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
