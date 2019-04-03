//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as im;
import 'videoRoute.dart';

void main() => runApp(MyApp());

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
  String path (bool isSwi){
    if(isSwi)
      return "assets/bunny.mp4";
    return "assets/bunnyShort.mp4";
  }

  void _changeTextState() {
    setState(() {
      _textAppState = "You have not yet seleted any image";
    });
  }
/*
  void _cameraSelection() async{
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera);
    final image = FirebaseVisionImage.fromFile(imageFile);
    final LabelDetector labelDetector = FirebaseVision.instance.labelDetector();
    final List<Label> labels = await labelDetector.detectInImage(image);
    for (Label label in labels) {
      final text = label.label;
      final entityId = label.entityId;
      final confidence = label.confidence;
    }

    setState(() {
      _textAppState = "It is in " + *//*text +*//* ", " + *//*entityId +*//* ", " + *//*confidence.toString() +*//* " (camera).";
    });
  }*/

  void _gallerySelection() async{
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 100.0,
        maxHeight: 100.0);
    /*im.Image image = new im.Image(1,1);
    im.fill(image, im.getColor(255, 100, 200));*/
    im.Image image = im.decodeImage(imageFile.readAsBytesSync());
    int pixelInfo = image.getPixel(image.width~/2, image.height~/2);
    int red = pixelInfo & 0xff;
    int blue = (pixelInfo>>16) & 0xff;
    int green = (pixelInfo>>8) & 0xff;

    setState(() {
      _textAppState = "It is in rgb(" + red.toString() + ", " + green.toString() + ", " + blue.toString() + ") (gallery).";
    });
  }

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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized sto make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_textAppState',
            ),
            FlatButton(
              child: Icon(Icons.camera_alt),
              textColor: Colors.grey,
              onPressed: _tempCameraSelection,//_cameraSelection,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _changeTextState,
        child: Text("Clear"),
      ),
    );
  }
}



