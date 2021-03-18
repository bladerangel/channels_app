import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/menu_provider.dart';

class MenuWidget extends StatefulWidget {
  final void Function(int index) onPressed;
  const MenuWidget({
    @required this.onPressed,
    Key key,
  }) : super(key: key);
  @override
  MenuWidgetState createState() => MenuWidgetState();
}

class MenuWidgetState extends State<MenuWidget> {
  MenuProvider _menuProvider;
  bool _init = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_init) {
      _menuProvider = Provider.of<MenuProvider>(context, listen: true);
      _init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width + 90) / 24;
    final height = (MediaQuery.of(context).size.height + 90) / 8;
    return Opacity(
      opacity: _menuProvider.isOpen ? 1 : 0.01,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black54,
        child: Padding(
          padding: EdgeInsets.only(bottom: height),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _menuProvider.logos
                .map(
                  (logo) => FlatButton(
                    onPressed: () {
                      widget.onPressed(_menuProvider.logos.indexOf(logo));
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      radius: _menuProvider.logos.indexOf(logo) ==
                              _menuProvider.index
                          ? width + 5
                          : width,
                      child: CircleAvatar(
                        radius: width,
                        backgroundImage: NetworkImage(logo),
                        backgroundColor: Colors.greenAccent,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
