import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import './providers/channels_provider.dart';
import './providers/video_provider.dart';
import './screens/home_screen.dart';
import './providers/permission_provider.dart';
import './providers/update_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: PermissionProvider(),
        ),
        ChangeNotifierProvider.value(
          value: UpdateProvider(),
        ),
        ChangeNotifierProvider.value(
          value: VideoProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ChannelsProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Channels App',
        home: HomeScreen(),
      ),
    );
  }
}
