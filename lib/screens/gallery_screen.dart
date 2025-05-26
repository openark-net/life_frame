import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../widgets/gallery_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  late PhotoJournalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PhotoJournalController>();
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
      _controller.loadMoreEntries();
    }
  }

  Future<void> _onRefresh() async {
    await _controller.refreshEntries();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Gallery')),
      child: SafeArea(
        child: Obx(() {
          if (_controller.isLoading && _controller.paginatedEntries.isEmpty) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final entries = _controller.paginatedEntries
              .where(
                (entry) =>
                    entry.stitchedPhotoPath != null &&
                    entry.stitchedPhotoPath!.isNotEmpty,
              )
              .toList();

          if (entries.isEmpty && !_controller.isLoading) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(onRefresh: _onRefresh),
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.photo_on_rectangle,
                          size: 80,
                          color: CupertinoColors.systemGrey3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No photos yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemGrey3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start your daily photo journey!',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: _onRefresh),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < entries.length) {
                        return GalleryImage(entry: entries[index]);
                      } else if (_controller.hasMorePages) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          child: const Center(
                            child: Text(
                              '📸',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    childCount:
                        entries.length +
                        (_controller.hasMorePages || _controller.isLoadingMore
                            ? 1
                            : 1),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
