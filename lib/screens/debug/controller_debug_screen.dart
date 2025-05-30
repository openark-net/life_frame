import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';
import '../../services/storage_service.dart';
import '../../models/daily_entry.dart';
import '../../utils/location_formatter.dart';

class ControllerDebugScreen extends StatefulWidget {
  const ControllerDebugScreen({super.key});

  @override
  State<ControllerDebugScreen> createState() => _ControllerDebugScreenState();
}

class _ControllerDebugScreenState extends State<ControllerDebugScreen> {
  String? _testResult;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();
    final storageService = Get.find<StorageService>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildControllerState(controller),
              const SizedBox(height: 20),
              _buildStorageData(storageService),
              const SizedBox(height: 20),
              _buildTestActions(controller),
              if (_testResult != null) ...[
                const SizedBox(height: 20),
                _buildTestResult(),
              ],
              const SizedBox(height: 20),
              _buildEntriesViewer(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Controller Debug',
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildControllerState(PhotoJournalController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controller State',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStateRow(
            'Has Today Photo',
            controller.hasTodayPhoto.toString(),
          ),
          _buildStateRow('Is Loading', controller.isLoading.toString()),
          _buildStateRow('Current Date', controller.currentDate),
          _buildStateRow(
            'Total Photos Count',
            controller.totalPhotosCount.toString(),
          ),
          _buildStateRow('Current Page', controller.currentPage.toString()),
          _buildStateRow('Has More Pages', controller.hasMorePages.toString()),
          _buildStateRow(
            'Is Loading More',
            controller.isLoadingMore.toString(),
          ),
          _buildStateRow(
            'Today Back Photo',
            controller.todayBackPhoto.isEmpty
                ? 'None'
                : controller.todayBackPhoto,
          ),
          _buildStateRow(
            'Today Front Photo',
            controller.todayFrontPhoto.isEmpty
                ? 'None'
                : controller.todayFrontPhoto,
          ),
          _buildStateRow('Streak', controller.getStreak().toString()),
          const SizedBox(height: 8),
          if (controller.todayEntry != null) ...[
            const Text(
              'Today Entry Details:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _buildEntryDetails(controller.todayEntry!),
          ] else
            const Text(
              'No today entry',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageData(StorageService storageService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Service Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: storageService.getPhotosDirectoryPath(),
            builder: (context, snapshot) {
              return _buildStateRow(
                'Photos Directory',
                snapshot.data ?? 'Loading...',
              );
            },
          ),
          FutureBuilder<int>(
            future: storageService.getTotalEntriesCount(),
            builder: (context, snapshot) {
              return _buildStateRow(
                'Total Entries in Storage',
                snapshot.data?.toString() ?? 'Loading...',
              );
            },
          ),
          FutureBuilder<bool>(
            future: storageService.hasTodayPhoto(),
            builder: (context, snapshot) {
              return _buildStateRow(
                'Storage Has Today Photo',
                snapshot.data?.toString() ?? 'Loading...',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestActions(PhotoJournalController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTestButton('Refresh Entries', () async {
                await controller.refreshEntries();
                _setTestResult('Entries refreshed');
              }),
              _buildTestButton('Load More Entries', () async {
                await controller.loadMoreEntries();
                _setTestResult('Load more entries attempted');
              }),
              _buildTestButton('Check Today Photo', () async {
                await controller.refreshEntries();
                _setTestResult('Today photo check completed via refresh');
              }),
              _buildTestButton('Get Today Entry', () async {
                final entry = await controller.getEntryByDate(DateTime.now());
                _setTestResult('Today entry: ${entry?.toString() ?? 'null'}');
              }),
              _buildTestButton('Calculate Streak', () {
                final streak = controller.getStreak();
                _setTestResult('Current streak: $streak days');
              }),
              _buildTestButton('Get Next Entry', () async {
                if (controller.todayEntry != null) {
                  final next = await controller.getNextEntry(
                    controller.todayEntry!.timestamp,
                  );
                  _setTestResult('Next entry: ${next?.toString() ?? 'null'}');
                } else {
                  _setTestResult('No today entry to get next from');
                }
              }),
              _buildTestButton('Get Previous Entry', () async {
                if (controller.todayEntry != null) {
                  final previous = await controller.getPreviousEntry(
                    controller.todayEntry!.timestamp,
                  );
                  _setTestResult(
                    'Previous entry: ${previous?.toString() ?? 'null'}',
                  );
                } else {
                  _setTestResult('No today entry to get previous from');
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Test Result',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _testResult = null;
                  });
                },
                child: const Icon(CupertinoIcons.clear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_testResult!, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEntriesViewer(PhotoJournalController controller) {
    final entries = controller.allEntries;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Entries (${entries.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text(
              'No entries found',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: CupertinoColors.systemGrey,
              ),
            )
          else
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground.resolveFrom(
                        context,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    child: _buildEntryDetails(entries[index]),
                  );
                },
              ),
            ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: const Text('Previous'),
                ),
                Text('${_currentPage + 1} / ${entries.length}'),
                CupertinoButton(
                  onPressed: _currentPage < entries.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntryDetails(DailyEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date: ${entry.date}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('Timestamp: ${entry.timestamp.toString()}'),
        Text('Photo Path: ${entry.photoPath}'),
        Text(
          'Location: ${getFormattedLocation(entry.latitude, entry.longitude)}',
        ),
        const SizedBox(height: 8),
        Text(
          'Valid: ${entry.isValid()}',
          style: TextStyle(
            color: entry.isValid()
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _setTestResult(String result) {
    setState(() {
      _testResult = result;
    });
  }
}
