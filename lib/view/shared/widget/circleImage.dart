
import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {
  final ImageProvider imageProvider;
  double height;
  double width;
  CircleImage(this.imageProvider, { Key key, this.height, this.width }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: Image(
        image: imageProvider,
        fit: BoxFit.fill,
        width: width,
        height: height,
      ),
    );
//    return Container(
//      width: width,
//      height: height,
//      decoration: BoxDecoration(
//          shape: BoxShape.circle,
//          image: DecorationImage(
//            fit: BoxFit.fill,
//            image: imageProvider,
//          )
//      ),
//    );
  }

}