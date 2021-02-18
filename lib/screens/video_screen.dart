import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import '../providers/video_provider.dart';
import '../providers/channels_provider.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  bool _init = true;
  VideoProvider _videoProvider;
  ChannelsProvider _channelsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await onPaused();
        break;
      case AppLifecycleState.resumed:
        await onResumed();
        break;
      default:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      _videoProvider = Provider.of<VideoProvider>(context);
      _channelsProvider = Provider.of<ChannelsProvider>(context);

      Future.delayed(Duration.zero, () async {
        await _channelsProvider.requestYoutubeChannels();
        await _videoProvider.initialize(_channelsProvider.currentChannel);
      });
    }
    _init = false;
  }

  Future<void> onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        await _channelsProvider.prevChannel();
        await _videoProvider.changeVideo(_channelsProvider.currentChannel);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        await _channelsProvider.nextChannel();
        await _videoProvider.changeVideo(_channelsProvider.currentChannel);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
        await _videoProvider.tooglePlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('aew');
          await _videoProvider.tooglePlay();
        },
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onEventKey,
        autofocus: true,
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(
                child: _videoProvider.isInitialize()
                    ? VlcPlayer(
                        controller: _videoProvider.controller,
                        aspectRatio: 16 / 9,
                        placeholder: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onPaused() async {
    await _videoProvider.stop();
  }

  Future<void> onResumed() async {
    await _videoProvider.play();
  }

  @override
  void dispose() {
    super.dispose();
    _videoProvider.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
