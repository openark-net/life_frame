import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/settings_option.dart';
import '../../openark_theme.dart';

class SettingsList extends StatelessWidget {
  final List<SettingsOption> options;

  const SettingsList({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: Colors.transparent,
        children: options.map((option) => _buildSettingsItem(option)).toList(),
      ),
    );
  }

  Widget _buildSettingsItem(SettingsOption option) {
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
