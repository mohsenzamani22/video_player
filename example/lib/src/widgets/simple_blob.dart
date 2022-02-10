import 'package:flutter/material.dart';

import '../../blobs.dart';

class SimpleBlob extends StatelessWidget {
  final double? size;
  final BlobData blobData;
  final bool debug;
  final Widget? child;
  final BlobStyles? styles;

  const SimpleBlob({
    required this.blobData,
    this.size,
    this.debug = false,
    this.styles,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: RepaintBoundary(
        child: CustomPaint(
          child: child,
          painter: BlobPainter(
            blobData: blobData,
            debug: debug,
            styles: styles,
          ),
        ),
      ),
    );
  }
}
