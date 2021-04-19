import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:video_player/video_player.dart';

import 'models/melody_model.dart';
import 'models/record_model.dart';
import 'models/user_model.dart';

VideoPlayerController? _controller;

class PostFullscreen extends StatefulWidget {
  final Record? record;
  final User? singer;
  final Melody? melody;
  const PostFullscreen({
    Key? key,
    this.record,
    this.singer,
    this.melody,
  }) : super(key: key);
  @override
  _PostFullscreenState createState() => _PostFullscreenState();
}

class _PostFullscreenState extends State<PostFullscreen> {
  bool isLiked = false;
  bool isLikeEnabled = true;
  var likes = [];

  bool play = true;

  bool _isFollowing = false;

  bool _scrollable = true;

  Record? _record;
  ScrollDirection _scrollDirection = ScrollDirection.reverse;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      print(_pageController.position.userScrollDirection.toString());
      if (_pageController.position.userScrollDirection != _scrollDirection) {
        print('direction changed');
        setState(() {
          _scrollable = true;
        });
      }
      if (_pageController.position.userScrollDirection ==
          ScrollDirection.forward) {
        print('swiped down');
      } else {
        print('swiped up');
      }

      _scrollDirection = _pageController.position.userScrollDirection;
    });
    if (widget.record != null) {
      setState(() {
        _record = widget.record!;
      });
    }
    initVideoPlayer(_record!.url!);
  }

  initVideoPlayer(String url) async {
    if (_controller != null) {
      //await _controller.dispose();
      setState(() {
        _controller = null;
      });
    }
    _controller = VideoPlayerController.network(url)
      ..addListener(() {
        // if (mounted) {
        //   setState(() {});
        // }
      })
      ..setLooping(false)
      ..initialize().then((value) {
        _controller!.play();
        _controller!.setLooping(false);
        print('aspect ratio: ${_controller!.value.aspectRatio}');
      });
  }

  @override
  void dispose() {
    disposePlayer();
    super.dispose();
  }

  disposePlayer() async {
    await _controller!.pause();
    _controller!.removeListener(() {});
    await _controller!.dispose();
    if (mounted) {
      setState(() {
        _controller = null;
      });
    }
  }

  late DragStartDetails startVerticalDragDetails;
  late DragUpdateDetails updateVerticalDragDetails;

  Future<bool> _onBackPressed() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Container(
              width: 120,
              child: Icon(Icons.music_note),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            widget.record != null
                ? SimpleGestureDetector(
                    onVerticalSwipe: (SwipeDirection swipeDirection) {
                      if (swipeDirection == SwipeDirection.up &&
                          _scrollDirection == ScrollDirection.forward) {
                        setState(() {
                          _scrollable = true;
                        });
                        _pageController.animateToPage(_page + 1,
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeOut);
                        print('Swipe up');
                      } else if (swipeDirection == SwipeDirection.down &&
                          _scrollDirection == ScrollDirection.reverse) {
                        setState(() {
                          _scrollable = true;
                        });
                        _pageController.animateToPage(_page - 1,
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeOut);
                        print('Swipe down');
                      }
                    },
                    child: PageView.builder(
                        controller: _pageController,
                        physics: !_scrollable
                            ? NeverScrollableScrollPhysics()
                            : null,
                        onPageChanged: (index) async {},
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return fullscreen();
                        }),
                  )
                : fullscreen(),
          ],
        ),
      ),
    );
  }

  PageController _pageController = new PageController();

  int _page = 0;

  fullscreen() {
    return Stack(
      children: <Widget>[
        TextButton(
            onPressed: () {
              setState(() {
                if (play) {
                  _controller?.pause();
                  play = !play;
                } else {
                  _controller?.play();
                  play = !play;
                }
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: _controller != null
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!))
                  : Container(),
            )),
        Padding(
          padding: EdgeInsets.only(top: 90, left: 10),
          child: Column(
            children: [
              Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(Icons.remove_red_eye,
                      size: 35, color: Colors.white)),
              Text('${_record?.views ?? 0}',
                  style: TextStyle(color: Colors.white))
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: InkWell(
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person),
                      ),
                    ),
                    title: _record != null
                        ? Text(
                            '${widget.singer?.name}',
                            style: TextStyle(color: Colors.white),
                          )
                        : Container(),
                    subtitle: _record != null
                        ? Text(
                            '@${widget.singer?.username}',
                            style: TextStyle(color: Colors.white),
                          )
                        : Container(),
                  ),
                  _record != null
                      ? Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: Text.rich(
                            TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: widget.melody?.name,
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ))
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 10, right: 10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 70,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {},
                            child: isLiked
                                ? Icon(Icons.thumb_up,
                                    size: 35, color: Colors.black)
                                : Icon(Icons.thumb_up,
                                    size: 35, color: Colors.white),
                          ),
                          Text('${_record?.likes ?? 0}',
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: Icon(Icons.sms,
                                    size: 35, color: Colors.white)),
                            Text('${_record!.comments ?? 0}',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: Icon(Icons.share,
                                    size: 35, color: Colors.white)),
                            Text('${_record?.shares ?? 0}',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
