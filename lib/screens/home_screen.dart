import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './video_screen.dart';
import './../providers/update_provider.dart';
import './../widgets/loading_widget.dart';
import './update_screen.dart';
import './../providers/permission_provider.dart';
import './../widgets/permission_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UpdateProvider _updateProvider;
  PermissionProvider _permissionProvider;
  bool _init = true;

  @override
  void initState() {
    super.initState();
    _updateProvider = Provider.of<UpdateProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_init) {
      _permissionProvider =
          Provider.of<PermissionProvider>(context, listen: true);
      await _permissionProvider.check();
      _init = false;
    }
  }

  Future<bool> init() async {
    return await _updateProvider.checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _init
          ? Container()
          : _permissionProvider.isPermission
              ? FutureBuilder(
                  future: init(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? LoadingWidget()
                          : snapshot.data
                              ? UpdateScreen()
                              : VideoScreen(),
                )
              : PermissionWidget(),
    );
  }
}
