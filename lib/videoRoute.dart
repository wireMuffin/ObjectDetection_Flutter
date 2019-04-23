import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class VideoRoute extends StatefulWidget {
  final String path;
  final String detectedClass;

  VideoRoute({Key key, this.path, this.detectedClass}) : super(key: key);
  @override
  _VideoRouteState createState() => _VideoRouteState();
}

class _VideoRouteState extends State<VideoRoute> {
  VideoPlayerController _controller;

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

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


  /*_controller.value.initialized
  ? AspectRatio(
  aspectRatio: _controller.value.aspectRatio,
  child: VideoPlayer(_controller),
  )
      : Container(),*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: Text(widget.detectedClass),
      ),
      body: Center(
        child: Column(
            children: <Widget>[
              _controller.value.initialized?
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : Container(),
            ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: ()async {
            String data = await getFileData("assets/" + widget.detectedClass + ".txt");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text(widget.detectedClass == "Cannot find any match" ? "Sorry" : "Information of " + widget.detectedClass),
                  content: new Text(data),
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
            );
          },
          child: Icon(Icons.info),

        ),
    );
    }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}