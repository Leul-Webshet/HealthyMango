// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _pickImage = ImagePicker();
  File? imagePath;
  late List _result;
  // late String _confindnce;

  String _name = '';
  String _number = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  fromCamera() async {
    final XFile? image = await _pickImage.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        imagePath = File(image.path);
      });
    }
  }

  fromGallary() async {
    final XFile? image =
        await _pickImage.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imagePath = File(image.path);
      });
    }
  }

  Future loadModel() async {
    Tflite.close();
    var result = await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

 Future applyModel(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2, //Change
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _result = res!;

      // Code need to be understood
      String str = _result[0]["label"];
      _name = str.substring(2);
      // _confindnce = _result != null?(_result[0]['Confidence']*100.0.toString().substring(0,2)+'%'):"";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Detect disease'),
          centerTitle: true,
          backgroundColor: Color(0xFFFF8242),
        ),
        body: Container(
          child: imagePath == null
              ? Text('Select Image')
              : Column(
                  children: [
                    Image.file(File(imagePath!.path)),
                    Text('Status:$_name'),
                  ],
                ),
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          FloatingActionButton(
            backgroundColor: Color(0xFFFF8242),
            onPressed: () {
              fromCamera();
            },
            child: Icon(Icons.camera_alt_outlined),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              backgroundColor: Color(0xFFFF8242),
              onPressed: () {
                fromGallary();
              },
              child: Icon(Icons.browse_gallery_outlined))
        ]),
      ),
    );
  }
}
