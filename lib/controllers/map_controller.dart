import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/daily_entry.dart';
import '../services/storage_service.dart';
import '../controllers/photo_journal_controller.dart';
import '../screens/photo_detail_screen.dart';

class MapController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMoreEntries = false.obs;
  final RxList<DailyEntry> displayedEntries = <DailyEntry>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  
  static const int _pageSize = 50;
  int _currentPage = 0;
  bool _hasMorePages = true;
  
  Completer<GoogleMapController>? _mapController;
  
  static const CameraPosition _defaultCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 2.0,
  );

  CameraPosition get defaultCameraPosition => _defaultCameraPosition;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void onMapCreated(GoogleMapController controller) {
    if (_mapController?.isCompleted == false) {
      _mapController?.complete(controller);
    }
  }

  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
      _currentPage = 0;
      _hasMorePages = true;
      displayedEntries.clear();
      markers.clear();
      
      await _loadNextPage();
      await _loadAllPages();
      
    } catch (e) {
      print('MapController: Error loading initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllPages() async {
    while (_hasMorePages && !isLoadingMoreEntries.value) {
      await _loadNextPage();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasMorePages || isLoadingMoreEntries.value) return;

    try {
      isLoadingMoreEntries.value = true;
      
      final entries = await _storageService.getEntriesPage(_currentPage, _pageSize);
      
      if (entries.isEmpty) {
        _hasMorePages = false;
        return;
      }

      displayedEntries.addAll(entries);
      await _addMarkersForEntries(entries);
      
      _currentPage++;
      
      if (entries.length < _pageSize) {
        _hasMorePages = false;
      }
      
    } catch (e) {
      print('MapController: Error loading page $_currentPage: $e');
    } finally {
      isLoadingMoreEntries.value = false;
    }
  }

  Future<void> _addMarkersForEntries(List<DailyEntry> entries) async {
    final newMarkers = <Marker>{};
    
    for (final entry in entries) {
      if (entry.latitude.abs() <= 90 && entry.longitude.abs() <= 180) {
        final marker = Marker(
          markerId: MarkerId(entry.date),
          position: LatLng(entry.latitude, entry.longitude),
          infoWindow: InfoWindow(
            title: entry.date,
            snippet: 'Tap to view photo',
          ),
          onTap: () => _onMarkerTapped(entry),
        );
        newMarkers.add(marker);
      }
    }
    
    markers.addAll(newMarkers);
  }

  void _onMarkerTapped(DailyEntry entry) {
    try {
      final photoJournalController = Get.find<PhotoJournalController>();
      
      Navigator.of(Get.context!).push(
        CupertinoPageRoute(
          builder: (context) => PhotoDetailScreen(
            controller: photoJournalController,
            initialEntry: entry,
          ),
        ),
      );
    } catch (e) {
      print('MapController: Error opening photo detail: $e');
    }
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }

  Future<void> moveToEntry(DailyEntry entry) async {
    if (_mapController?.isCompleted == true) {
      final controller = await _mapController!.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(entry.latitude, entry.longitude),
          15.0,
        ),
      );
    }
  }

  void setMapController(Completer<GoogleMapController> controller) {
    _mapController = controller;
  }

  @override
  void onClose() {
    _mapController = null;
    super.onClose();
  }
}