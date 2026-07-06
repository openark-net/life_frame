import 'package:flutter/cupertino.dart';

import '../../models/camera_lens_option.dart';
import '../../theme.dart';

class LensSelector extends StatelessWidget {
  final List<CameraLensOption> options;
  final CameraLensOption? selected;
  final bool enabled;
  final ValueChanged<CameraLensOption> onSelect;

  const LensSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _LensButton(
              option: option,
              isSelected: identical(option, selected),
              enabled: enabled,
              onSelect: onSelect,
            ),
        ],
      ),
    );
  }
}

class _LensButton extends StatelessWidget {
  final CameraLensOption option;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<CameraLensOption> onSelect;

  const _LensButton({
    required this.option,
    required this.isSelected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onSelect(option) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.white.withValues(alpha: 0.25)
              : CupertinoColors.white.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          option.label,
          style: TextStyle(
            color: isSelected ? AppColors.yellow : CupertinoColors.white,
            fontSize: isSelected ? 14 : 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
