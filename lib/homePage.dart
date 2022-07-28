// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

import 'package:percent_indicator/percent_indicator.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Modifed code
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
    });
  }

  importModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
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
    double temp = _output[0]['confidence']*100.toInt();
    String con = temp.toStringAsFixed(2);
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 12,),
                    CircularPercentIndicator(
                      radius: 60.0,
                      
                      animation: true,
                      animationDuration: 1200,
                      lineWidth: 15.0,
                      progressColor: Color(0xFFFF8242),
                      circularStrokeCap: CircularStrokeCap.butt,
                      percent: _output[0]['confidence'],
                      center: Text(con+' %'),
                    ),
                    SizedBox(height: 15),
                    // Text('${_output[0]['confidence']%100}')
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
