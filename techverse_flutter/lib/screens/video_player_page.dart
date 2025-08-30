import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerPage extends StatefulWidget{
  final String url;
  const VideoPlayerPage({super.key,required this.url});
  @override
  State<VideoPlayerPage> createState()=> _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage>{
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState(){
    super.initState();
    _controller=VideoPlayerController.networkUrl(Uri.parse(widget.url))
    ..initialize().then((_){
      setState(() {});
      _chewieController=ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
      );
    });
  }
  @override
  void dispose(){
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _chewieController!=null && _controller.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      )
    );
  }
}