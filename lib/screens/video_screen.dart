import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fijkplayer/fijkplayer.dart';

import '../widgets/menu_widget.dart';
import '../providers/video_provider.dart';
import '../providers/channels_provider.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  VideoProvider _videoProvider;
  ChannelsProvider _channelsProvider;
  final _menu = GlobalKey<MenuWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoProvider = Provider.of<VideoProvider>(context, listen: false);
    _channelsProvider = Provider.of<ChannelsProvider>(context, listen: false);
  }

  Future<void> init() async {
    await _channelsProvider.initialize();
    await _videoProvider.initialize(await _channelsProvider.dataSource);
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

  Future<void> onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
          !_menu.currentState.isOpen) {
        _menu.currentState.index = _channelsProvider.prevChannel();
        await _videoProvider.changeVideo(await _channelsProvider.dataSource);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
          !_menu.currentState.isOpen) {
        _menu.currentState.index = _channelsProvider.nextChannel();
        await _videoProvider.changeVideo(await _channelsProvider.dataSource);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
          _menu.currentState.isOpen) {
        _menu.currentState.index = _channelsProvider.prevChannel();
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &
          _menu.currentState.isOpen) {
        _menu.currentState.index = _channelsProvider.nextChannel();
      }
      if (event.isKeyPressed(LogicalKeyboardKey.select)) {
        _menu.currentState.toogle();
        if (!_menu.currentState.isOpen) {
          await _videoProvider.changeVideo(await _channelsProvider.dataSource);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_menu.currentState.isOpen) {
            _menu.currentState.toogle();
            _menu.currentState.index = _channelsProvider.currentChannelIndex;
            return false;
          } else {
            dispose();
            return true;
          }
        },
        child: GestureDetector(
          onTap: () {
            _menu.currentState.toogle();
          },
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: onEventKey,
            autofocus: true,
            child: Container(
              color: Colors.black,
              child: FutureBuilder(
                future: init(),
                builder: (ctx, snapshot) => Stack(
                  children: snapshot.connectionState == ConnectionState.waiting
                      ? [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Carregando Canais...',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      : [
                          Center(
                            child: FijkView(
                              color: Colors.black,
                              player: _videoProvider.controller,
                            ),
                          ),
                          MenuWidget(
                            key: _menu,
                            index: _channelsProvider.currentChannelIndex,
                            logos: _channelsProvider.channels,
                            onPressed: (index) async {
                              _menu.currentState.toogle();
                              _menu.currentState.index =
                                  _channelsProvider.setChannel(index);
                              await _videoProvider.changeVideo(
                                  await _channelsProvider.dataSource);
                            },
                          ),
                        ],
                ),
              ),
            ),
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
    _channelsProvider.dispose();
    _videoProvider.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
