import 'package:flutter/material.dart';

import '../../blobs.dart';
import '../config.dart';

class BlobClipper extends CustomClipper<Path> {
  final String? id;
  final int edgesCount;
  final int minGrowth;
  BlobClipper({
    this.id,
    this.edgesCount = BlobConfig.edgesCount,
    this.minGrowth = BlobConfig.minGrowth,
  });

  @override
  Path getClip(Size size) {
    var blobData = BlobGenerator(
      id: id,
      edgesCount: edgesCount,
      minGrowth: minGrowth,
      size: size,
    ).generate();
    return connectPoints(blobData.curves!);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
