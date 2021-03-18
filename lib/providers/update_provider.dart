import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class Release {
  final String version;
  final String lastVersion;
  final String downloadLink;

  Release({this.version, this.lastVersion, this.downloadLink});
}

class Task {
  final Release release;
  final String localPath;
  String taskId;
  double progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  Task({this.release, this.localPath});
}

class UpdateProvider with ChangeNotifier {
  Task _task;
  Release _release;
  String _url =
      'https://api.github.com/repos/bladerangel/channels_app/releases/latest';

  Task get task => _task;

  Future<bool> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    Response response = await get('$_url');
    dynamic json = jsonDecode(response.body);

    String lastVersion =
        (json['tag_name'] as String).replaceAll(RegExp(r'v'), '');
    String downloadLink = ((json['assets'] as List<dynamic>)
        .first['browser_download_url'] as String);

    _release = Release(
      version: version,
      lastVersion: lastVersion,
      downloadLink: downloadLink,
    );
    return version != lastVersion;
  }

  Future<void> initialize() async {
    bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    String localPath = await createLocalPath();
    _task = Task(release: _release, localPath: localPath);
    await requestDownload();
    notifyListeners();
  }

  void bindBackgroundIsolate() {
    ReceivePort port = ReceivePort();

    bool isSuccess = IsolateNameServer.registerPortWithName(
        port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (_task.taskId == id) {
        _task.status = status;
        _task.progress = progress.toDouble();
        notifyListeners();
      }
    });
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<String> createLocalPath() async {
    String localPath = (await getExternalStorageDirectory()).path +
        Platform.pathSeparator +
        'Download';

    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return localPath;
  }

  Future<void> requestDownload() async {
    _task.taskId = await FlutterDownloader.enqueue(
      url: _task.release.downloadLink,
      savedDir: _task.localPath,
    );
  }

  Future<void> openDownloadedFile() async {
    await FlutterDownloader.open(taskId: _task.taskId);
  }
}
