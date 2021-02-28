import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Channel {
  final String name;
  final String primary;
  final String secondary;
  final String logo;

  Channel({this.name, this.primary, this.secondary, this.logo});
}

class ChannelsProvider with ChangeNotifier {
  List<String> _channels;
  int _currentChannelIndex;
  int _channelIndex;

  int get currentChannelIndex => _currentChannelIndex;

  List<String> get channels => [..._channels];

  Future<void> initialize() async {
    final response =
        await get('https://channelsdotnet.herokuapp.com/channel/logos');

    final list = jsonDecode(response.body) as List<dynamic>;
    _channels = list.map((data) => data as String).toList();
    _channelIndex = 0;
  }

  Future<String> get dataSource async {
    _currentChannelIndex = _channelIndex;

    final response = await get(
        'https://channelsdotnet.herokuapp.com/channel/$_currentChannelIndex');
    return response.body;
  }

  int nextChannel() {
    if (_channelIndex >= 0 && _channelIndex < _channels.length - 1) {
      _channelIndex++;
    } else {
      _channelIndex = 0;
    }
    return _channelIndex;
  }

  int prevChannel() {
    if (_channelIndex > 0 && _channelIndex <= _channels.length - 1) {
      _channelIndex--;
    } else {
      _channelIndex = _channels.length - 1;
    }
    return _channelIndex;
  }
}
