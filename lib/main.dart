import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/channels_provider.dart';
import './providers/video_provider.dart';
import './screens/video_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: VideoProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ChannelsProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Channels App',
        home: VideoScreen(),
      ),
    );
  }
}
