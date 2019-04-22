import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as im;
import 'videoRoute.dart';
import 'package:flutter/services.dart';

/*import 'package:http/http.dart';
import 'package:image_picker_saver/image_picker_saver.dart' as ips;
import 'dart:io';*/

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
  var _picUrl = 'http://192.168.31.237/capture?_cb=1555929991989';
  var _image = Image.network('http://192.168.31.237/capture?_cb=1555929991989');

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
    imageCache.clear();
    _picCounter++;
    setState(() {
      _image = Image.network(_picUrl + _picCounter.toString());
    });

    print("here!");
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
          _image,
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



