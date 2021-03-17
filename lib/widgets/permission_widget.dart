import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './../providers/permission_provider.dart';

class PermissionWidget extends StatefulWidget {
  @override
  _PermissionWidgetState createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  PermissionProvider _permissionProvider;

  @override
  void initState() {
    super.initState();
    _permissionProvider =
        Provider.of<PermissionProvider>(context, listen: false);
  }

  Future<void> onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.select)) {
        await _permissionProvider.check();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onEventKey,
      autofocus: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                'Aplicativo requer permissões para o acesso.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            FlatButton(
              color: Colors.blueAccent,
              onPressed: () async {
                await _permissionProvider.check();
              },
              child: Text(
                'Requerer permissões',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
