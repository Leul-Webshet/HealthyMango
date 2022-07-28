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
  //Modifed code
  bool _loading = true;
  File? _image;
  late List _output;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    importModel();
  }

  classifyImage(File img) async {
    var outcome = await Tflite.runModelOnImage(
        path: img.path,
        numResults: 4,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _output = outcome!;
      _loading = false;
    });
  }

  importModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }

  pickImage() async {
    // var photo = await picker.pickImage(source: ImageSource.camera);
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    //checking for error
    if (photo == null) return null;

    setState(() {
      _image = File(photo.path);
    });

    classifyImage(_image!);
  }

  pickGallery() async {
    // var photo = await picker.pickImage(source: ImageSource.gallery);
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    //checking for error
    if (photo == null) return null;

    setState(() {
      _image = File(photo.path);
    });

    classifyImage(_image!);
  }

  // End of Modefied code

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
          child: _image == null
              ? Container(
                  padding: EdgeInsets.all(12),
                  child: Column(children: [
                    Text(
                      'Healthy Mango',
                      style:
                          TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        'This App detectes the health status of mango. Take a picture of Mango leaf or choose From Gallery to see the status')
                  ]),
                )
              : Column(
                  children: [
                    Container(
                      height: 350,
                      width: 350,
                      child: Image.file(File(_image!.path)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    
                    Text(
                      '${_output[0]['label']}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text('${_output[0]['confidence']%100}')
                  ],
                ),
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          FloatingActionButton(
            backgroundColor: Color(0xFFFF8242),
            onPressed: () {
              pickImage();
            },
            child: Icon(Icons.camera_alt_outlined),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
              backgroundColor: Color(0xFFFF8242),
              onPressed: () {
                pickGallery();
              },
              child: Icon(Icons.browse_gallery_outlined))
        ]),
      ),
    );
  }
}
