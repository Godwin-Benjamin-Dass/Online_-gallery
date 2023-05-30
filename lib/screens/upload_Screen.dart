import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire_gallery/screens/uploadDoc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class Upload_Screen extends StatefulWidget {
  const Upload_Screen({super.key});

  @override
  State<Upload_Screen> createState() => _Upload_ScreenState();
}

class _Upload_ScreenState extends State<Upload_Screen> {
  bool uploading = false;
  double val = 0;

  CollectionReference? imgRef;
  firebase_storage.Reference? ref;
  List<File> _image = [];
  final picker = ImagePicker();
  var prog = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Uploading Page',
            style: TextStyle(color: Colors.deepOrange),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: prog == ""
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // prog = "1";
                          uploading = true;
                        });
                        uploadFile()
                            .whenComplete(() => Navigator.of(context).pop());
                      },
                      child: Text('Upload'))
                  : ElevatedButton(
                      onPressed: () {},
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )),
            ),
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => UploadDocs())
            //           );
            //     },
            //     child: Text('docs'))
          ],
        ),
        body: Stack(
          children: [
            GridView.builder(
                itemCount: _image.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  return index == 0
                      ? Center(
                          child: IconButton(
                            onPressed: () =>
                                [!uploading ? ChooseImage() : null],
                            icon: Icon(Icons.add, color: Colors.deepOrange),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: FileImage(_image[index - 1]),
                                  fit: BoxFit.cover)),
                        );
                }),
            uploading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Text(
                            'Uploading....',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CircularProgressIndicator(
                          value: val,
                          color: Colors.deepOrange,
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ));
  }

  ChooseImage() async {
    final PickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(PickedFile!.path));
    });
    if (PickedFile!.path == null) retrivelostdata();
  }

  Future<void> retrivelostdata() async {
    final LostData responce = await picker.getLostData();
    if (responce.isEmpty) {
      return;
    }
    if (responce.file != null) {
      setState(() {
        _image.add(File(responce.file!.path));
      });
    } else {
      print(responce.file);
    }
  }

  Future uploadFile() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("images/${Path.basename(img.path)}");
      await ref?.putFile(img).whenComplete(() async {
        await ref?.getDownloadURL().then((value) {
          final _CollectionReference =
              FirebaseFirestore.instance.collection("imageUrls").doc();
          return _CollectionReference.set({
            'user': FirebaseAuth.instance.currentUser?.email.toString(),
            'url': value,
            'ref': Path.basename(img.path),
            'time': DateTime.now().toString(),
            'id': _CollectionReference.id
          }).then((value) {
            i++;
          });
        });
      });
    }
  }
}
