import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';

import '../../controllers/daily_entry_controller.dart';
import '../../models/daily_entry.dart';
import '../../models/pagination_result.dart';
import '../../widgets/debug/database/action_buttons.dart';

class PhotoDebugScreen extends StatefulWidget {
  const PhotoDebugScreen({super.key});

  @override
  State<PhotoDebugScreen> createState() => _PhotoDebugScreenState();
}

class _PhotoDebugScreenState extends State<PhotoDebugScreen> {
  final DailyEntryController _controller = Get.find<DailyEntryController>();
  final Talker _talker = Get.find<Talker>();

  List<DailyEntry> _entries = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  int _totalEntries = 0;
  int? _currentCursor;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _listenToEntriesChanges();
  }

  void _listenToEntriesChanges() {
    _controller.entriesVersion$.listen((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await _loadPage(cursor: null);
  }

  Future<void> _loadPage({int? cursor}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      _talker.debug('Loading page with cursor: $cursor');

      final result = await _controller.list(
        cursor: cursor,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _entries = result.results;
          _hasNextPage = result.hasNextPage;
          _hasPreviousPage = result.hasPreviousPage;
          _totalEntries = result.total;
          _currentCursor = cursor;
          _isLoading = false;
        });
      }

      _talker.info(
        'Loaded ${result.results.length} entries, total: ${result.total}',
      );
    } catch (e, st) {
      _talker.handle(e, st, 'Error loading database entries');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_entries.isNotEmpty && _hasNextPage) {
      final lastEntry = _entries.last;
      await _loadPage(cursor: lastEntry.timestamp.millisecondsSinceEpoch);
    }
  }

  Future<void> _loadPreviousPage() async {
    if (_hasPreviousPage) {
      await _loadPage(cursor: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Database ($_totalEntries)'),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.refresh),
                onPressed: _loadInitialData,
              ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_hasError) _buildErrorBanner(),
            _buildPaginationControls(),
            Expanded(
              child: _isLoading && _entries.isEmpty
                  ? _buildLoadingState()
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ActionButtons(entries: _entries),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: CupertinoColors.systemRed.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error loading entries',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemRed,
                  ),
                ),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalEntries == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: _hasPreviousPage
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            minSize: 0,
            onPressed: _hasPreviousPage ? _loadPreviousPage : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.chevron_left, size: 16),
                SizedBox(width: 4),
                Text('First', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Text(
            'Showing ${_entries.length} of $_totalEntries',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: _hasNextPage
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
            minSize: 0,
            onPressed: _hasNextPage ? _loadNextPage : null,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('More', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Icon(CupertinoIcons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading entries...',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }
}
