import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import './../providers/update_provider.dart';

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  UpdateProvider _updateProvider;
  bool _init = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_init) {
      _updateProvider = Provider.of<UpdateProvider>(context, listen: true);
      await _updateProvider.initialize();
      _init = false;
    }
  }

  Future<void> onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.select)) {
        if (_updateProvider.task.status == DownloadTaskStatus.complete) {
          await _updateProvider.openDownloadedFile();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 2;
    return _updateProvider.task != null
        ? RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: onEventKey,
            autofocus: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Atualizando versão ${_updateProvider.task.release.version} para ${_updateProvider.task.release.lastVersion}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: LinearPercentIndicator(
                        width: width,
                        lineHeight: 40,
                        percent: _updateProvider.task.progress / 100,
                        center: Text(
                          '${_updateProvider.task.progress}%',
                          style: TextStyle(fontSize: 12),
                        ),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        backgroundColor: Colors.grey,
                        progressColor: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                _updateProvider.task.status == DownloadTaskStatus.complete
                    ? FlatButton(
                        color: Colors.blueAccent,
                        onPressed: () async {
                          await _updateProvider.openDownloadedFile();
                        },
                        child: Text(
                          'Instalar',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          )
        : Container();
  }
}
