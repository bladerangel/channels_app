import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Channel {
  final String name;
  final String primary;
  final String secondary;

  Channel({this.name, this.primary, this.secondary});
}

class ChannelsProvider with ChangeNotifier {
  List<Channel> _channels = [
    Channel(
        name: 'Rede Vida',
        primary:
            'https://www.youtube.com/channel/UC7MUmXqD_kEChxYFME0bdtg/live',
        secondary:
            'https://cvd1.cds.ebtcvd.net/live-redevida/smil:redevida.smil/playlist.m3u8'),
    Channel(
        name: 'Rede Século 21',
        primary:
            'https://www.youtube.com/channel/UC0APLxALWhTrAA00T4Y7Ulw/live',
        secondary: 'https://dhxt2zok2aqcr.cloudfront.net/live/rs21.m3u8'),
    Channel(
        name: 'Canção Nova',
        primary:
            'https://www.youtube.com/channel/UCVrKQMmA2ew9LFzeIDaOFgw/live',
        secondary:
            'http://tvajuhls-lh.akamaihd.net:80/i/tvdesk_1@147040/master.m3u8'),
    Channel(
        name: 'Tv Evangelizar',
        primary: null,
        secondary:
            'https://5f593df7851db.streamlock.net/evangelizar/tv/playlist.m3u8'),
    Channel(
        name: 'TV Aparecida',
        primary:
            'https://www.youtube.com/channel/UCfYrK5JU5EznsnK3wQE7iIg/live',
        secondary:
            'https://caikron.com.br:8082/padroeira/padroeira/playlist.m3u8'),
    Channel(
        name: 'Pai Eterno',
        primary: null,
        secondary:
            'https://59f1cbe63db89.streamlock.net:1443/teste01/_definst_/teste01/playlist.m3u8'),
  ];

  List<String> _currentChannels = [];

  String _currentChannel;

  String get currentChannel => _currentChannel;

  Future<void> requestYoutubeChannels() async {
    for (var channel in _channels) {
      try {
        if (channel.primary != null) {
          var response = await http.get(channel.primary);

          if (response.statusCode == 200) {
            String htmlToParse = response.body;
            RegExp exp = new RegExp(
                r"(https://manifest.googlevideo.com/api/manifest/hls_variant.+m3u8)");
            RegExpMatch match = exp.firstMatch(htmlToParse);
            _currentChannels.add(match.group(0));
          }
        } else {
          _currentChannels.add(channel.secondary);
        }
      } catch (error) {
        _currentChannels.add(channel.secondary);
      }
    }
    _currentChannel = _currentChannels[0];
  }

  Future<void> nextChannel() async {
    final index = _currentChannels.indexOf(_currentChannel);
    if (index >= 0 && index < _currentChannels.length - 1) {
      _currentChannel = _currentChannels[index + 1];
    } else {
      _currentChannel = _currentChannels[0];
    }
  }

  Future<void> prevChannel() async {
    final index = _currentChannels.indexOf(_currentChannel);
    if (index > 0 && index <= _currentChannels.length - 1) {
      _currentChannel = _currentChannels[index - 1];
    } else {
      _currentChannel = _currentChannels[_currentChannels.length - 1];
    }
  }
}
