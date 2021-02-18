import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  final index;
  final List<String> logos;
  final void Function(int index) onPressed;
  const MenuWidget({
    @required this.index,
    @required this.logos,
    @required this.onPressed,
    Key key,
  }) : super(key: key);
  @override
  MenuWidgetState createState() => MenuWidgetState();
}

class MenuWidgetState extends State<MenuWidget> {
  bool _isOpen = false;
  int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
  }

  bool get isOpen => _isOpen;

  int get index => _index;

  void toogle() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  set index(index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width + 90) / 24;
    final height = (MediaQuery.of(context).size.height + 90) / 8;
    return _isOpen
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black54,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: height, left: width + 30, right: width + 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.logos
                    .map((logo) => Expanded(
                          child: Container(
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                index = widget.logos.indexOf(logo);
                                widget.onPressed(index);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.greenAccent,
                                radius: widget.logos.indexOf(logo) == index
                                    ? width + 5
                                    : width,
                                child: CircleAvatar(
                                  radius: width,
                                  backgroundImage: NetworkImage(logo),
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          )
        : Container();
  }
}
