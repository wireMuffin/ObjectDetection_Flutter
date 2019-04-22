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
    /*floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying?
              _controller.pause()
              : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),*/
    );
    }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}