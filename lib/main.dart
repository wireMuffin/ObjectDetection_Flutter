import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as im;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tflite/tflite.dart';
import 'videoRoute.dart';
import 'dart:typed_data';

void main() => runApp(MyApp());
//This is the entrance of the whole program

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new MaterialApp(
      title: 'Object Detection App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Object Detection App'),
      debugShowCheckedModeBanner: false,
      //Do not show the debug banner in the top right corner of the App
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _textAppState = " ";
  bool isSwitched = true;
  var _detectedClass = "Cannot find any match";
  var _picCounter = 0;
  var _picUrl = 'http://192.168.31.1/capture?_cb=1555932915322?';
  var _image = Image.network('http://192.168.31.1/capture?_cb=1555932915322?');

  String path (var obj){
    if(obj == "mouse")
      return "assets/mouse.mp4";
    if(obj == "remote")
      return "assets/remote.mp4";
    if(obj == "cell phone")
      return "assets/cellphone.mp4";
    if(obj == "book")
      return "assets/book.mp4";
    return "assets/notfound.mp4";
  }
  //this is called when determining which video should be played when videoRoute is created.

  void _changeTextState() {
    setState(() {
      _textAppState = "You have not yet capture any image";
    });
  }
  //this is called when we need to update the text field on top of the App.

  void _externalCameraSelection() async{
    _picCounter++;

    var file = await DefaultCacheManager().getSingleFile(_picUrl + _picCounter.toString());
    im.Image image = im.decodeImage(file.readAsBytesSync());

    String res = await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt",
        numThreads: 1 // defaults to 1
    );

    print(res);

    Uint8List imageToByteListFloat32(
        im.Image image, int inputSize, double mean, double std) {
      var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
      var buffer = Float32List.view(convertedBytes.buffer);
      int pixelIndex = 0;
      for (var i = 0; i < inputSize; i++) {
        for (var j = 0; j < inputSize; j++) {
          var pixel = image.getPixel(j, i);
          buffer[pixelIndex++] = (im.getRed(pixel) - mean) / std;
          buffer[pixelIndex++] = (im.getGreen(pixel) - mean) / std;
          buffer[pixelIndex++] = (im.getBlue(pixel) - mean) / std;
        }
      }
      return convertedBytes.buffer.asUint8List();
    }

    var recognitions = await Tflite.detectObjectOnBinary(
        binary: imageToByteListFloat32(image, 416, 0.0, 255.0), // required
        model: "YOLO",
        threshold: 0.1,       // defaults to 0.1
        numResultsPerClass: 2,// defaults to 5
        blockSize: 32,        // defaults to 32
        numBoxesPerBlock: 5,  // defaults to 5
    );

    print("here");
    print(recognitions);

    setState(() {
      _image = Image.network(_picUrl + _picCounter.toString());
      //_textAppState = "It is in rgb(" + red.toString() + ", " + green.toString() + ", " + blue.toString();
    });
  }
  //this is called when getting an image from a web server, i.e ESP32's http server.

  void _internalCameraSelection() async{
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 100.0,
        maxHeight: 100.0
    );

    setState(() {
      _textAppState = "Now Loading...";
    });

    im.Image image = im.decodeImage(imageFile.readAsBytesSync());

    String res = await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt",
        numThreads: 1 // defaults to 1
    );


    Uint8List imageToByteListFloat32(
        im.Image image, int inputSize, double mean, double std) {
      var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
      var buffer = Float32List.view(convertedBytes.buffer);
      int pixelIndex = 0;
      for (var i = 0; i < inputSize; i++) {
        for (var j = 0; j < inputSize; j++) {
          var pixel = image.getPixel(j, i);
          buffer[pixelIndex++] = (im.getRed(pixel) - mean) / std;
          buffer[pixelIndex++] = (im.getGreen(pixel) - mean) / std;
          buffer[pixelIndex++] = (im.getBlue(pixel) - mean) / std;
        }
      }
      return convertedBytes.buffer.asUint8List();
    }

    var recognitions = await Tflite.detectObjectOnBinary(
      binary: imageToByteListFloat32(image, 416, 0.0, 255.0), // required
      model: "YOLO",
      threshold: 0.1,       // defaults to 0.1
      numResultsPerClass: 2,// defaults to 5
      blockSize: 32,        // defaults to 32
      numBoxesPerBlock: 5,  // defaults to 5
    );

    //print(recognitions.isEmpty);

    if (recognitions.isEmpty){
      _detectedClass = "Cannot find any match";
    } else {
      _detectedClass = recognitions[0]['detectedClass'].toString();
    }

    Navigator.push( context,
        new MaterialPageRoute(builder: (context) {
          return new VideoRoute(path: path(_detectedClass), detectedClass: _detectedClass,);//VideoRoute() is in videoRoute.dart
        })
    );

    setState(() {
      _textAppState = "";
    });
  }
  //this is called when capturing an image using the device's own camera.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$_textAppState',
                  ),
                Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          labelText: "IP Address",
                          hintText: "e.g 192.168.31.1",
                          prefixIcon: Icon(Icons.cloud)
                      ),
                      onChanged: (t){_picUrl = 'http://'+ t +'/capture?_cb=';
                      print(_picUrl);},
                    ),
                    TextField(
                      decoration: InputDecoration(
                          labelText: "Key Number",
                          hintText: "e.g 1555932915322",
                          prefixIcon: Icon(Icons.sort)
                      ),
                      obscureText: true,
                      onChanged: (t){_picUrl = _picUrl.substring(0, _picUrl.indexOf("=")+1) + t;
                      print(_picUrl);},
                    ),
                  ],
                ),
                  Padding(padding: EdgeInsets.all(16.0),),
                  FlatButton(
                    child: Icon(Icons.linked_camera),
                    textColor: Colors.blue,
                    onPressed: _externalCameraSelection,
                  ),
                  FlatButton(
                    child: Icon(Icons.photo_camera),
                    textColor: Colors.blue,
                    onPressed: _internalCameraSelection,
                  ),
                ]
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Help"),
                content: new Text("The wireless camera button is for external camera (i.e ESP32's camera).\n"
                    "The second camera button is for this device's internal camera."),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );},
        child: Icon(Icons.help),
      ),
    );
  }
}



