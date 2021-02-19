import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Channel {
  final String name;
  final String primary;
  final String secondary;
  String current;
  final String logo;

  Channel({this.name, this.primary, this.secondary, this.current, this.logo});
}

class ChannelsProvider with ChangeNotifier {
  List<Channel> _channels = [
    Channel(
        name: 'Rede Vida',
        primary:
            'https://www.youtube.com/channel/UC7MUmXqD_kEChxYFME0bdtg/live',
        secondary:
            'https://cvd1.cds.ebtcvd.net/live-redevida/smil:redevida.smil/playlist.m3u8',
        logo:
            'https://yt3.ggpht.com/ytc/AAUvwngEnqdSn-GwgmDpm8bRqDac4ifdEKEzPQWWmVu6Mw=s176-c-k-c0x00ffffff-no-rj-mo'),
    Channel(
        name: 'Rede Século 21',
        primary:
            'https://www.youtube.com/channel/UC0APLxALWhTrAA00T4Y7Ulw/live',
        secondary: 'https://dhxt2zok2aqcr.cloudfront.net/live/rs21.m3u8',
        logo:
            'https://yt3.ggpht.com/ytc/AAUvwniiad2DaiQ3OxyyO8m6Di-eXXoT-UsIFq8wZxfzNpA=s176-c-k-c0x00ffffff-no-rj-mo'),
    Channel(
        name: 'Canção Nova',
        primary:
            'https://www.youtube.com/channel/UCVrKQMmA2ew9LFzeIDaOFgw/live',
        secondary:
            'http://tvajuhls-lh.akamaihd.net:80/i/tvdesk_1@147040/master.m3u8',
        logo:
            'https://yt3.ggpht.com/ytc/AAUvwngMRf5HNCB0DfDHOcRqJ_pW_Z67lPtAwh14RdZCJg=s88-c-k-c0x00ffffff-no-rj'),
    Channel(
        name: 'Tv Evangelizar',
        primary: null,
        secondary:
            'https://5f593df7851db.streamlock.net/evangelizar/tv/playlist.m3u8',
        logo:
            'https://yt3.ggpht.com/ytc/AAUvwniHT0Rgo48OzPyqzqoIhWNkbhdPwcjgUl27zON6zg=s176-c-k-c0x00ffffff-no-rj-mo'),
    Channel(
        name: 'TV Aparecida',
        primary:
            'https://www.youtube.com/channel/UCfYrK5JU5EznsnK3wQE7iIg/live',
        secondary:
            'https://caikron.com.br:8082/padroeira/padroeira/playlist.m3u8',
        logo:
            'https://yt3.ggpht.com/ytc/AAUvwnjglMhubaA1iCiJhDRp1AFbM2vbH7eo13Q_S1qpYg=s176-c-k-c0x00ffffff-no-rj-mo'),
    Channel(
        name: 'Pai Eterno',
        primary: null,
        secondary:
            'https://59f1cbe63db89.streamlock.net:1443/teste01/_definst_/teste01/playlist.m3u8',
        logo:
            'https://yt3.ggpht.com/ytc/AAUvwnhun4onLfGYyvE5RgJUrlCP-IOtCx7iq8w8fNNPnQ=s176-c-k-c0x00ffffff-no-rj-mo'),
  ];

  Channel _channel;

  List<Channel> get channels => [..._channels];

  Channel get channel => _channel;

  get channelIndex => channels.indexOf(channel);

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
            channel.current = match.group(0);
          }
        } else {
          channel.current = channel.secondary;
        }
      } catch (error) {
        channel.current = channel.secondary;
      }
    }
    _channel = _channels[0];
  }

  void setChannel(int index) {
    _channel = _channels[index];
  }

  void nextChannel() {
    final index = channelIndex;
    if (index >= 0 && index < _channels.length - 1) {
      _channel = _channels[index + 1];
    } else {
      _channel = _channels[0];
    }
  }

  void prevChannel() {
    final index = channelIndex;
    if (index > 0 && index <= _channels.length - 1) {
      _channel = _channels[index - 1];
    } else {
      _channel = _channels[_channels.length - 1];
    }
  }
}
