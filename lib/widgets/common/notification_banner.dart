import 'dart:async';

import 'package:flutter/cupertino.dart';

enum NotificationPosition { top, bottom }

class NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final NotificationPosition position;
  final Duration displayDuration;
  final VoidCallback onDismissed;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.position,
    required this.displayDuration,
    required this.onDismissed,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  static const Duration _transitionDuration = Duration(milliseconds: 300);

  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _displayTimer;
  bool _isDismissing = false;

  bool get _isTop => widget.position == NotificationPosition.top;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: Offset(0, _isTop ? -1.5 : 1.5),
      end: Offset.zero,
    ).animate(curved);
    _fade = curved;
    _controller.forward();
    _displayTimer = Timer(widget.displayDuration, _dismiss);
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _displayTimer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: _isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(position: _slide, child: _buildCard(context)),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(widget.backgroundColor, context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
