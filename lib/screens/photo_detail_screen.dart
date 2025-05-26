import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../models/daily_entry.dart';

class PhotoDetailScreen extends StatefulWidget {
  final PhotoJournalController controller;
  final DailyEntry initialEntry;

  const PhotoDetailScreen({
    super.key,
    required this.controller,
    required this.initialEntry,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _nextPhotoAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _nextPhotoFadeAnimation;

  List<DailyEntry> _entries = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  final Random _random = Random();
  double _currentPhotoRotation = 0;
  double _nextPhotoRotation = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadEntries();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _nextPhotoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _nextPhotoFadeAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _nextPhotoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _generateRandomRotations();
  }

  void _generateRandomRotations() {
    _currentPhotoRotation = (_random.nextDouble() - 0.5) * 20 * pi / 180;
    _nextPhotoRotation = (_random.nextDouble() - 0.5) * 20 * pi / 180;
    
    // Ensure background photo has a significantly different angle
    while ((_currentPhotoRotation - _nextPhotoRotation).abs() < 10 * pi / 180) {
      _nextPhotoRotation = (_random.nextDouble() - 0.5) * 20 * pi / 180;
    }
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allEntries = await _getAllEntriesWithPhotos();
      final initialIndex = allEntries.indexWhere(
        (entry) => entry.date == widget.initialEntry.date,
      );

      setState(() {
        _entries = allEntries;
        _currentIndex = initialIndex >= 0 ? initialIndex : 0;
        _isLoading = false;
      });

      if (_entries.isNotEmpty) {
        _pageController = PageController(initialPage: _currentIndex);
        
        // Preload initial images to prevent flashing
        final currentImage = FileImage(File(_entries[_currentIndex].stitchedPhotoPath!));
        precacheImage(currentImage, context);
        
        if (_currentIndex < _entries.length - 1) {
          final nextImage = FileImage(File(_entries[_currentIndex + 1].stitchedPhotoPath!));
          precacheImage(nextImage, context);
        }
        
        _startNextPhotoPreview();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<DailyEntry>> _getAllEntriesWithPhotos() async {
    final allEntries = widget.controller.allEntries
        .where(
          (entry) =>
              entry.stitchedPhotoPath != null &&
              entry.stitchedPhotoPath!.isNotEmpty &&
              File(entry.stitchedPhotoPath!).existsSync(),
        )
        .toList();

    allEntries.sort((a, b) => b.date.compareTo(a.date));
    return allEntries;
  }

  void _startNextPhotoPreview() {
    if (_currentIndex < _entries.length - 1) {
      // Preload the next image to prevent flashing
      final nextImage = FileImage(File(_entries[_currentIndex + 1].stitchedPhotoPath!));
      precacheImage(nextImage, context);
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _nextPhotoAnimationController.forward();
        }
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Preload current image to prevent flashing
    final currentImage = FileImage(File(_entries[index].stitchedPhotoPath!));
    precacheImage(currentImage, context);

    _animationController.reset();
    _nextPhotoAnimationController.reset();
    _generateRandomRotations();
    _animationController.forward();
    _startNextPhotoPreview();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nextPhotoAnimationController.dispose();
    if (_entries.isNotEmpty) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: Center(
          child: CupertinoActivityIndicator(color: CupertinoColors.white),
        ),
      );
    }

    if (_entries.isEmpty) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.black.withValues(alpha: 0.8),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Get.back(),
            child: const Icon(
              CupertinoIcons.xmark,
              color: CupertinoColors.white,
            ),
          ),
        ),
        child: const Center(
          child: Text(
            'No photos to display',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  CupertinoColors.black.withValues(alpha: 0.8),
                  CupertinoColors.black,
                ],
              ),
            ),
          ),

          // Photo viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              return _buildPhotoView(_entries[index], index);
            },
          ),

          // Header with close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CupertinoColors.black.withValues(alpha: 0.7),
                      CupertinoColors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      onPressed: () => Get.back(),
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: CupertinoColors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoView(DailyEntry entry, int index) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Next photo preview (behind current photo)
          if (index < _entries.length - 1)
            AnimatedBuilder(
              animation: _nextPhotoFadeAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _nextPhotoRotation,
                  child: Transform.scale(
                    scale: 0.85,
                    child: Transform.translate(
                      offset: const Offset(25, 20),
                      child: Container(
                        margin: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.white.withValues(
                              alpha: _nextPhotoFadeAnimation.value * 0.1,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 3 / 5,
                          child: Opacity(
                            opacity: _nextPhotoFadeAnimation.value,
                            child: Image.file(
                              File(_entries[index + 1].stitchedPhotoPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Current photo
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _currentPhotoRotation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: CupertinoColors.white.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 3 / 5,
                          child: Image.file(
                            File(entry.stitchedPhotoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: CupertinoColors.systemGrey6,
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_triangle,
                                    size: 40,
                                    color: CupertinoColors.systemGrey3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
