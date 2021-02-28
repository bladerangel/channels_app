import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import '../widgets/menu_widget.dart';
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
  final _menu = GlobalKey<MenuWidgetState>();

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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_init) {
      _videoProvider = Provider.of<VideoProvider>(context);
      _channelsProvider = Provider.of<ChannelsProvider>(context, listen: false);
      await _channelsProvider.initialize();
      await _videoProvider.initialize(await _channelsProvider.dataSource);
    }
    _init = false;
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
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: onEventKey,
          autofocus: true,
          child: Container(
            color: Colors.black,
            child: Stack(
              children: _videoProvider.isInitialize
                  ? [
                      Center(
                        child: VlcPlayer(
                          controller: _videoProvider.controller,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                      MenuWidget(
                        key: _menu,
                        index: _channelsProvider.currentChannelIndex,
                        logos: _channelsProvider.channels,
                      ),
                    ]
                  : [
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
                    ],
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
