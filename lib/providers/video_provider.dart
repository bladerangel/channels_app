import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoProvider with ChangeNotifier {
  VideoPlayerController _controller;

  VideoPlayerController get controller => _controller;

  Future<void> initialize(String dataSource) async {
    await _controller?.pause();
    _controller = VideoPlayerController.network(dataSource);
    await _controller.initialize();
    await _controller.play();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
