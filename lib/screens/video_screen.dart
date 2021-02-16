import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

import '../providers/channels_provider.dart';
import '../providers/video_provider.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoProvider _videoProvider;
  bool _init = true;

  ChannelsProvider _channelsProvider;

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
        await _videoProvider.initialize(_channelsProvider.currentChannel);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        await _channelsProvider.nextChannel();
        await _videoProvider.initialize(_channelsProvider.currentChannel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onEventKey,
        autofocus: true,
        child: Center(
          child: _videoProvider.controller != null &&
                  _videoProvider.controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _videoProvider.controller.value.aspectRatio,
                  child: VideoPlayer(_videoProvider.controller),
                )
              : Container(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoProvider.dispose();
  }
}
