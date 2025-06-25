import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/debug_option.dart';
import '../../openark_theme.dart';

class DebugList extends StatelessWidget {
  final List<DebugOption> options;

  const DebugList({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: Colors.transparent,
        children: options.map((option) => _buildDebugItem(option)).toList(),
      ),
    );
  }

  Widget _buildDebugItem(DebugOption option) {
    return CupertinoListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: option.iconBackgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(option.icon, color: option.iconColor, size: 16),
      ),
      title: Text(option.title),
      trailing:
          option.trailing ??
          (option.isLink
              ? const Icon(
                  CupertinoIcons.chevron_right,
                  color: OpenArkColors.primary,
                  size: 16,
                )
              : null),
      onTap: option.onTap,
    );
  }
}