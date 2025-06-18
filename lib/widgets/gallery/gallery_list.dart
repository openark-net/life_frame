import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import 'package:life_frame/widgets/gallery/empty_gallery_state.dart';
import '../../controllers/daily_entry_controller.dart';
import '../../models/daily_entry.dart';
import '../../models/pagination_result.dart';
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
  late Talker _talker;
  late Worker _entriesWorker;

  List<DailyEntry> entries = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNextPage = false;
  bool hasError = false;
  String? errorMessage;
  int? nextCursor;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DailyEntryController>();
    _talker = Get.find<Talker>();
    _scrollController.addListener(_onScroll);

    // Listen for changes to entries and refresh gallery
    _entriesWorker = ever(_controller.entriesVersion$, (_) {
      _talker.debug('Entries changed, refreshing gallery');
      _loadInitialEntries();
    });

    _loadInitialEntries();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _entriesWorker.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEntries();
    }
  }

  Future<void> _loadInitialEntries() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      _talker.debug('Loading initial gallery entries');
      final result = await _controller.list(pageSize: 20);

      setState(() {
        entries = result.results;
        hasNextPage = result.hasNextPage;
        nextCursor = result.results.isNotEmpty
            ? result.results.last.timestamp.millisecondsSinceEpoch
            : null;
        isLoading = false;
      });

      _talker.info('Loaded ${result.results.length} initial gallery entries');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to load initial gallery entries');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load photos';
      });
    }
  }

  Future<void> _loadMoreEntries() async {
    if (isLoadingMore || !hasNextPage || nextCursor == null) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      _talker.debug('Loading more gallery entries with cursor: $nextCursor');
      final result = await _controller.list(cursor: nextCursor, pageSize: 20);

      setState(() {
        entries.addAll(result.results);
        hasNextPage = result.hasNextPage;
        nextCursor = result.results.isNotEmpty
            ? result.results.last.timestamp.millisecondsSinceEpoch
            : null;
        isLoadingMore = false;
      });

      _talker.info(
        'Loaded ${result.results.length} additional gallery entries',
      );
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to load more gallery entries');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    try {
      _talker.debug('Refreshing gallery entries');
      final result = await _controller.list(pageSize: 20);

      setState(() {
        entries = result.results;
        hasNextPage = result.hasNextPage;
        nextCursor = result.results.isNotEmpty
            ? result.results.last.timestamp.millisecondsSinceEpoch
            : null;
        hasError = false;
        errorMessage = null;
      });

      _talker.info('Refreshed gallery with ${result.results.length} entries');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to refresh gallery entries');
    }
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed.resolveFrom(context),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Something went wrong',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: _loadInitialEntries,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(child: CupertinoActivityIndicator(radius: 16)),
    );
  }

  Widget _buildGalleryContent() {
    if (entries.isEmpty) {
      return const SliverFillRemaining(child: EmptyGalleryState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index < entries.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GalleryImage(entry: entries[index]),
          );
        }

        return GalleryPaginationFooter(
          hasMorePages: hasNextPage,
          isLoadingMore: isLoadingMore,
        );
      }, childCount: entries.length + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _onRefresh),
        if (isLoading && entries.isEmpty)
          _buildLoadingState()
        else if (hasError && entries.isEmpty)
          _buildErrorState()
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildGalleryContent(),
          ),
      ],
    );
  }
}
