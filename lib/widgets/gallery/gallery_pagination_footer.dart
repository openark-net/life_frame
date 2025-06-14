// lib/widgets/gallery/gallery_pagination_footer.dart
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../background/background_utils.dart';

class GalleryPaginationFooter extends StatelessWidget {
  final bool hasMorePages;
  final bool isLoadingMore;

  const GalleryPaginationFooter({
    super.key,
    required this.hasMorePages,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    if (hasMorePages || isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: BackgroundUtils.buildRandomShape(math.Random(3), 1.0),
      ),
    );
  }
}
