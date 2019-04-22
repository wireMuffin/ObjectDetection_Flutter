import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as im;
import 'videoRoute.dart';
import 'dart:typed_data';

//import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MyApp());
//This is the entrance of the whole program

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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
  var _textAppState = "You have not yet seleted any image";
  bool isSwitched = true;

  var _picCounter = 0;
  var _picUrl = 'http://192.168.31.237/capture?_cb=1555932915322?';
  var _image = Image.network('http://192.168.31.237/capture?_cb=1555932915322');

  String path (bool isSwi){
    if(isSwi)
      return "assets/bunny.mp4";
    return "assets/bunnyShort.mp4";
  }
  //this is called when determining which video should be played when videoRoute is created.

  void _changeTextState() {
    setState(() {
      _textAppState = "You have not yet seleted any image";
    });
  }
  //this is called when we need to update the text field on top of the App.

  void _cameraSelection() async{
    _picCounter++;

    var file = await DefaultCacheManager().getSingleFile(_picUrl + _picCounter.toString());
    im.Image image = im.decodeImage(file.readAsBytesSync());
    /*int pixelInfo = image.getPixel(image.width~/2, image.height~/2);
    int red = pixelInfo & 0xff;
    int blue = (pixelInfo>>16) & 0xff;
    int green = (pixelInfo>>8) & 0xff;*/

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
        threshold: 0.3,       // defaults to 0.1
        numResultsPerClass: 2,// defaults to 5
        blockSize: 32,        // defaults to 32
        numBoxesPerBlock: 5,  // defaults to 5
    );

    print("here");
    print(recognitions);

    //await Tflite.close();

    setState(() {
      _image = Image.network(_picUrl + _picCounter.toString());
      //_textAppState = "It is in rgb(" + red.toString() + ", " + green.toString() + ", " + blue.toString();
    });
  }
  //this is called when getting an image from a web server, i.e ESP32's http server.

  void _gallerySelection() async{
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 100.0,
        maxHeight: 100.0);
    //restrict the size of the image, because decoding binary image file using Flutter in iOS device is very slow.
    im.Image image = im.decodeImage(imageFile.readAsBytesSync());
    int pixelInfo = image.getPixel(image.width~/2, image.height~/2);
    int red = pixelInfo & 0xff;
    int blue = (pixelInfo>>16) & 0xff;
    int green = (pixelInfo>>8) & 0xff;

    setState(() {
      _textAppState = "It is in rgb(" + red.toString() + ", " + green.toString() + ", " + blue.toString() + ") (gallery).";
    });
  }
  //this is called when selecting an image from the built-in library.

  void _tempCameraSelection() async{
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 100.0,
        maxHeight: 100.0
    );
    /*im.Image image = new im.Image(1,1);
    im.fill(image, im.getColor(255, 100, 200));*/

    im.Image image = im.decodeImage(imageFile.readAsBytesSync());
    int pixelInfo = image.getPixel(image.width~/2, image.height~/2);
    int red = pixelInfo & 0xff;
    int blue = (pixelInfo>>16) & 0xff;
    int green = (pixelInfo>>8) & 0xff;

    setState(() {
      _textAppState = "It is in rgb(" + red.toString() + ", " + green.toString() + ", " + blue.toString() + ") (camera).";
    });
  }
  //this is called when capturing an image using the device's own camera.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      //appBar is the top bar of the App
      body: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //_image,
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$_textAppState',
                  ),
                  FlatButton(
                    child: Icon(Icons.camera_alt),
                    textColor: Colors.grey,
                    onPressed: _cameraSelection,
                  ),
                  FlatButton(
                    child: Icon(Icons.photo_album),
                    textColor: Colors.blue,
                    onPressed: _gallerySelection,
                  ),
                  FlatButton(
                    child: Icon(Icons.camera_alt),
                    textColor: Colors.blue,
                    onPressed: _tempCameraSelection,
                  ),
                  FlatButton(
                    child: Icon(Icons.video_library),
                    textColor: Colors.blue,
                    onPressed: () {
                      Navigator.push( context,
                          new MaterialPageRoute(builder: (context) {
                            return new VideoRoute(path: path(isSwitched));//VideoRoute() is in videoRoute.dart
                          }));
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Short"),
                      Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(() {
                            isSwitched = value;
                          });
                        },
                        activeTrackColor: Colors.lightBlueAccent,
                        activeColor: Colors.blue,
                      ),
                      Text("Long"),
                    ],
                  ),
                ]
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeTextState,
        child: Text("Clear"),
      ),
    );
  }
}



