import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionProvider with ChangeNotifier {
  bool _isPermission = false;
  bool get isPermission => _isPermission;

  Future<void> check() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        _isPermission = true;
      }
    } else {
      _isPermission = true;
    }
    notifyListeners();
  }
}
