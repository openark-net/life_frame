import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/daily_entry_controller.dart';
import '../../models/daily_entry.dart';
import '../gallery_image.dart';
import 'gallery_pagination_footer.dart';

class GalleryList extends StatefulWidget {
  const GalleryList({super.key});

  @override
  State<GalleryList> createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  final ScrollController _scrollController = ScrollController();
  late DailyEntryController _controller;
  late List<DailyEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DailyEntryController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // _controller.loadMoreEntries();
    }
  }

  Future<void> _onRefresh() async {
    // TODO:
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _onRefresh),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < entries.length) {
                return GalleryImage(entry: entries[index]);
              }
              return GalleryPaginationFooter(
                hasMorePages: false,
                isLoadingMore: false,
              );
            }, childCount: entries.length + 1),
          ),
        ),
      ],
    );
  }
}
