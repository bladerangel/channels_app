import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  final index;
  final List<String> logos;
  const MenuWidget({
    @required this.index,
    @required this.logos,
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
    return Opacity(
      opacity: _isOpen ? 1 : 0.01,
      child: Container(
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
                .map(
                  (logo) => Expanded(
                    child: CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      radius: widget.logos.indexOf(logo) == index
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
