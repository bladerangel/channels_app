import 'package:flutter/foundation.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoProvider with ChangeNotifier {
  VlcPlayerController _controller;

  VlcPlayerController get controller => _controller;

  Future<void> initialize(String dataSource) async {
    _controller = VlcPlayerController.network(
      dataSource,
      hwAcc: HwAcc.FULL,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
        extras: ['--adaptive-logic=highest', '--adaptive-maxheight=720'],
      ),
    );
    notifyListeners();
  }

  bool get isInitialize => _controller != null;

  Future<void> stop() async {
    await _controller.stop();
  }

  Future<void> play() async {
    await _controller.play();
  }

  Future<void> changeVideo(String dataSource) async {
    await _controller.setMediaFromNetwork(dataSource);
  }

  @override
  void dispose() async {
    super.dispose();
    await _controller.dispose();
  }
}
