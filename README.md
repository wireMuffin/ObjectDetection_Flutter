# Object Recognition using machine learning and image source from ESP32

A Flutter project that plays specific video when the app detected the corresponding object (by reading captured image from ESP32).

## Getting Started (From Very Beginning)

Tutorial on deploying your Flutter development environment:

- [Check this out first if you are in **mainland China**](https://flutter.dev/community/china)
- [Windows](https://flutter.dev/docs/get-started/install/windows)
- [macOS](https://flutter.dev/docs/get-started/install/macos)
- [Linux](https://flutter.dev/docs/get-started/install/linux)

A few resources to get you started if this is your first time getting in touch with Flutter:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view the 

[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Really Getting Started (with IntelliJ)

### Create an empty project

1. Open IntelliJ and Create a new project in menu->File->Project..

2. Choose Flutter project and change ***[$yourFlutterPath]*** to your path of Flutter SDK, then press Next.

   ![1.FlutterSDKLocation](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j6to48fj30x10u0anb.jpg)

3. Change ***[$ProjectName]***, ***[$ProjectLocation]***, ***[$Description]*** and ***[$Organisation]*** into your project name, location of you project, description of your project and your organisation(You can just type anything if you do not have an organisation), then press Finish.

![2.NewProject](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j713ic7j30x10u0dt5.jpg)

3. Now you have your first Flutter project created:

   ![3.FirstFlutterProject](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j7apjorj31b30u0h8p.jpg)

   - The green box is your project structure.
   - The blue box is your main working area.
   - The red circle allows you to select your debugging device including simulated Android device, simulated iOS device (macOS only), real Android device and real iOS device (macOS only) if you plugged them in your computer.
   - The orange circle allows you to run the App on your device if everything is ready for debug.

------

### Modify the project

1. Things that need to be changed from the default empty project:

   1. `pubspec.yaml`

      1. "image picker" and "video_player" packages is imported by adding 2 lines in `[$ProjectName]/pubspec.yaml` :

         ```yaml
         dependencies:
           flutter:
             sdk: flutter
           #newly added packages
           image_picker: ^0.5.0+6
           video_player: ^0.10.0+4 
           #end newly added packages
         ```

      2. 2 video are imported as assets:

         2 video files, "bunnyShort.mp4" and "bunny.mp4" are added to `[$ProjectName]/assets/` , and 3 lines are added to `[$ProjectName]/pubspec.yaml`:

         ```yaml
           assets:
             - assets/bunny.mp4
             - assets/bunnyShort.mp4
         ```

         - these 2 lines are added **BELOW** "flutter: " with level 2 of indentation.

      3. After you modify the `pubspec.yaml`, 

   2. **ONLY if you faced AndroidX crashes in a Flutter app**: 

      1. First fixing method:  Using **Android Studio** to migrate the App to Android X(Recommened by Flutter officially):

         - With Android Studio 3.2 and higher, you can quickly migrate an existing project to use AndroidX by selecting **Refactor > Migrate to AndroidX** from the menu bar.
         - If you encounter any problem using this approach, follows the [detailed instruction](https://developer.android.com/jetpack/androidx/migrate) by Flutter official. Or you can choose to use manual fixing as following.

      2. Second fixing method: Manually Migrate to Android X (Method used by me):

         1. In `[$ProjectName]/android/gradle/wrapper/gradle-wrapper.properties` change the line starting with `distributionUrl` like this:

            ```properties
            distributionUrl=https\://services.gradle.org/distributions/gradle-4.10.2-all.zip
            ```

         2. In `android/build.gradle`, replace:

            ```groovy
            dependencies {
                classpath 'com.android.tools.build:gradle:3.2.1'
            }
            ```

            by

            ```groovy
            dependencies {
                classpath 'com.android.tools.build:gradle:3.3.0'
            }
            ```

         3. In `android/gradle.properties`, append

            ```properties
            android.enableJetifier=true
            android.useAndroidX=true
            ```

         4. In `android/app/build.gradle`:

            Under `android {`, make sure `compileSdkVersion` and `targetSdkVersion` are at least 28.

         5. Replace all deprecated libraries with the AndroidX equivalents. For instance, if you’re using the default `.gradle` files make the following changes:

            In `android/app/build.gradle`, replace

            ```groovy
            testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
            ```

            by

            ```groovy
            testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
            ```

            Under  `dependencies {`, replace

            ```groovy
            androidTestImplementation 'com.android.support.test:runner:1.0.2'
            androidTestImplementation 'com.android.support.test.espresso:espresso-core:3.0.2'
            
            ```

            by

            ```groovy
            androidTestImplementation 'androidx.test:runner:1.1.1'
            androidTestImplementation 'androidx.test.espresso:espresso-core:3.1.1'
            
            ```

Now you have every precautions settled.

------

### Code

All code in Flutter should be placed in `[$ProjectName]/lib`, we have a total of 2 .dart file:

#### `main.dart`

This is the main program of the whole project.

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as im;
import 'videoRoute.dart';
import 'package:flutter/services.dart';

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
  var _image = Image.network('http://172.20.10.6/capture?_cb=1554370194299');

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
    setState(() {
      _image = Image.network('http://172.20.10.6/capture?_cb=1554370194299');
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

```

Modify the default `main.dart` file as above.

#### `videoRoute.dart`

This is a route for playing video.

```dart
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoRoute extends StatefulWidget {
  final String path;
  VideoRoute({Key key, this.path}) : super(key: key);
  @override
  _VideoRouteState createState() => _VideoRouteState();
}

class _VideoRouteState extends State<VideoRoute> {
  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        widget.path)
      ..addListener((){
        if(!_controller.value.isPlaying){
          Navigator.pop(context);
        }
      })
      /*
      this listener listen for the playing status of the video
      i.e when the video is not playing(the video is ended or paused(not provided in this route))
      this route will be pop out of the route stack, i.e. return to the main route.
      */
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),

        ),
    );
    }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

```

Create the above `videoRoute.dart` file in `[$ProjectName]/lib`:

Right click on the structure area's `lib` folder, choose New->Dart File.



![4.videoRouteCreation](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j949ogtj31d90u0h84.jpg)Then named the name to `videoRoute` and press OK.

![5.videoRouteNaming](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j8y486ij30o60c4wh7.jpg)

Modify this `videoRoute.dart` as above.



All things are settled, you can now debug this program with your device(s).

------

### Debuging using real device

You can only debug this program with real device, because simulator does not support camera function.

*Also, only Android device is supported at this stage.*

1. Connect your Android device to your computer.

2. Click on the menu in the red circle in IntelliJ:

   ![3.FirstFlutterProject](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j8c9vrej31b30u043e.jpg)

3. Then choose your device:

   ![6.DeviceSelection](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j8kwso1j30ke0663zi.jpg)

4. Then click on the run icon in IntelliJ next to the orange circle as shown above.

5. You can now see the debugging information in the green box:

   ![7.Debugging](https://tva1.sinaimg.cn/large/006y8mN6gy1g79j8u1bm9j31b30u01kx.jpg)

6. You can now edit the source code and perform **hot reload** by clicking on the lightning button in the red circle above.

------

## Getting realease

If you finish all debuging, you can have your mobile App released:

1. Goto the path of your project in shell:

   ![Screenshot 2019-04-25 at 21.40.09](https://tva1.sinaimg.cn/large/006y8mN6gy1g79jaa35k0j316c0so10o.jpg)

2. Then input

   ```
   flutter clean
   flutter build apk
   ```

3. You should have your apk in `[$yourPathOfProject]/build/app/outputs/apk`.