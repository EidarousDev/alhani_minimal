import 'package:flutter/material.dart';

import 'models/melody_model.dart';
import 'models/record_model.dart';
import 'models/user_model.dart';
import 'post_fullscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PostFullscreen(
        record: Record(
            url:
                'https://firebasestorage.googleapis.com/v0/b/dubsmash-75a05.appspot.com/o/records%2FCzNU80YyITYeIKoRSp4h%2FHxbJQfwjBn59UyEmt95n.mp4?alt=media&token=6c94f3e5-ae23-4edb-87f3-96d7b8e91117',
            duration: 15,
            thumbnailUrl:
                "https://firebasestorage.googleapis.com/v0/b/dubsmash-75a05.appspot.com/o/records_thumbnails%2FCzNU80YyITYeIKoRSp4h%2FHxbJQfwjBn59UyEmt95n.png?alt=media&token=638fb8cf-5a74-4ce0-9a97-241664eeb68f",
            views: 14),
        singer: User(name: 'John Doe', username: 'john_doe'),
        melody: Melody(name: 'Test'),
      ),
    );
  }
}
