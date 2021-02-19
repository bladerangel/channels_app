import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
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
        home: Center(
          child: SplashScreen(
            seconds: 5,
            navigateAfterSeconds: VideoScreen(),
            title: new Text(
              'Carregando Canais...',
              style: new TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            backgroundColor: Colors.black,
            loaderColor: Colors.greenAccent,
          ),
        ),
      ),
    );
  }
}
