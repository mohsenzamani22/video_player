import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';

class RotateInpirationExample extends StatefulWidget {
  const RotateInpirationExample({Key? key}) : super(key: key);

  @override
  _RotateInpirationExampleState createState() =>
      _RotateInpirationExampleState();
}

class _RotateInpirationExampleState extends State<RotateInpirationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 200), vsync: this);
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: (animation.value * 0.6) * 360.0,
                  child: Blob.fromID(
                    size: 200,
                    id: ['6-8-34659'],
                    styles: BlobStyles(
                      color: const Color(0x272f00ff),
                      fillType: BlobFillType.fill,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: animation.value * 360.0,
                  child: Blob.animatedRandom(
                    size: 220,
                    // id: ['6-8-6090'],
                    controller: BlobController(),
                    styles: BlobStyles(
                      color: const Color(0x402f00ff),
                      fillType: BlobFillType.fill,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
