import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fijkplayer/fijkplayer.dart';

import './../widgets/menu_widget.dart';
import './../providers/video_provider.dart';
import './../providers/channels_provider.dart';
import './../widgets/loading_widget.dart';
import './../providers/menu_provider.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  VideoProvider _videoProvider;
  ChannelsProvider _channelsProvider;
  MenuProvider _menuProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoProvider = Provider.of<VideoProvider>(context, listen: false);
    _channelsProvider = Provider.of<ChannelsProvider>(context, listen: false);
    _menuProvider = Provider.of<MenuProvider>(context, listen: false);
  }

  Future<void> init() async {
    await _channelsProvider.initialize();
    await _videoProvider.initialize(await _channelsProvider.dataSource);
    _menuProvider.setIndex(_channelsProvider.currentChannelIndex);
    _menuProvider.setLogos(_channelsProvider.channels);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await onPaused();
        break;
      default:
        break;
    }
  }

  Future<void> onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
          !_menuProvider.isOpen) {
        _menuProvider.setIndex(_channelsProvider.prevChannel());
        await _videoProvider.changeVideo(await _channelsProvider.dataSource);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
          !_menuProvider.isOpen) {
        _menuProvider.setIndex(_channelsProvider.nextChannel());
        await _videoProvider.changeVideo(await _channelsProvider.dataSource);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
          _menuProvider.isOpen) {
        _menuProvider.setIndex(_channelsProvider.prevChannel());
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &
          _menuProvider.isOpen) {
        _menuProvider.setIndex(_channelsProvider.nextChannel());
      }
      if (event.isKeyPressed(LogicalKeyboardKey.select)) {
        _menuProvider.toogle();
        if (!_menuProvider.isOpen) {
          await _videoProvider.changeVideo(await _channelsProvider.dataSource);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? LoadingWidget()
          : WillPopScope(
              onWillPop: () async {
                if (_menuProvider.isOpen) {
                  _menuProvider.toogle();
                  _menuProvider.setIndex(_channelsProvider.currentChannelIndex);
                  return false;
                } else {
                  dispose();
                  return true;
                }
              },
              child: GestureDetector(
                onTap: () {
                  _menuProvider.toogle();
                },
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: onEventKey,
                  autofocus: true,
                  child: Stack(
                    children: [
                      Center(
                        child: FijkView(
                          color: Colors.black,
                          player: _videoProvider.controller,
                        ),
                      ),
                      MenuWidget(
                        onPressed: (index) async {
                          _menuProvider.toogle();
                          _menuProvider
                              .setIndex(_channelsProvider.setChannel(index));
                          await _videoProvider
                              .changeVideo(await _channelsProvider.dataSource);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> onPaused() async {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    super.dispose();
    _channelsProvider.dispose();
    _videoProvider.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
