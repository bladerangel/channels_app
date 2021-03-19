import 'package:flutter/foundation.dart';
import 'package:fijkplayer/fijkplayer.dart';

class VideoProvider with ChangeNotifier {
  FijkPlayer _controller;

  FijkPlayer get controller => _controller;

  Future<void> initialize(String dataSource) async {
    _controller = FijkPlayer();
    await _controller.setDataSource(dataSource, autoPlay: true);
  }

  Future<void> stop() async {
    await _controller.reset();
  }

  Future<void> changeVideo(String dataSource) async {
    await stop();
    await _controller.setDataSource(dataSource, autoPlay: true);
  }

  @override
  void dispose() async {
    super.dispose();
    await _controller.release();
    _controller.dispose();
  }
}
