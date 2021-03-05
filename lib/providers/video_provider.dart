import 'package:flutter/foundation.dart';
import 'package:fijkplayer/fijkplayer.dart';

class VideoProvider with ChangeNotifier {
  FijkPlayer _controller;

  FijkPlayer get controller => _controller;

  Future<void> initialize(String dataSource) async {
    _controller = FijkPlayer();
    await _controller.setDataSource(dataSource, autoPlay: true);
    notifyListeners();
  }

  bool get isInitialize => _controller != null;

  Future<void> stop() async {
    await _controller.pause();
  }

  Future<void> play() async {
    await _controller.start();
  }

  Future<void> changeVideo(String dataSource) async {
    await _controller.reset();
    await _controller.setDataSource(dataSource, autoPlay: true);
    notifyListeners();
  }

  @override
  void dispose() async {
    super.dispose();
    await _controller.release();
    _controller.dispose();
  }
}
