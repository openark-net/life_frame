import 'package:flutter/cupertino.dart';

class MenuOption {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLink;

  const MenuOption({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.trailing,
    this.onTap,
    this.isLink = false,
  });

  MenuOption copyWith({
    String? title,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    Widget? trailing,
    VoidCallback? onTap,
    bool? isLink,
  }) {
    return MenuOption(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      trailing: trailing ?? this.trailing,
      onTap: onTap ?? this.onTap,
      isLink: isLink ?? this.isLink,
    );
  }
}
