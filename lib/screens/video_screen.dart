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

class _VideoScreenState extends State<VideoScreen> {
  bool _init = true;
  VideoProvider _videoProvider;
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
        await _videoProvider.changeVideo(_channelsProvider.currentChannel);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        await _channelsProvider.nextChannel();
        await _videoProvider.changeVideo(_channelsProvider.currentChannel);
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
        child: Container(
          color: Colors.black,
          child: Stack(children: [
            Center(
              child: _videoProvider.isInitialize()
                  ? VlcPlayer(
                      controller: _videoProvider.controller,
                      aspectRatio: 16 / 9,
                      placeholder: Center(child: CircularProgressIndicator()),
                    )
                  : CircularProgressIndicator(),
            ),
          ]),
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
