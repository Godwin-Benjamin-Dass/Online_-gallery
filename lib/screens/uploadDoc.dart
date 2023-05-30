import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadDocs extends StatefulWidget {
  const UploadDocs({super.key});

  @override
  State<UploadDocs> createState() => _UploadDocsState();
}

class _UploadDocsState extends State<UploadDocs> {
  getfile() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(onPressed: () {}, child: Text('Select files'))),
    );
  }
}
