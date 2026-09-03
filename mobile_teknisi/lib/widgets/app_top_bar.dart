import 'package:flutter/material.dart';
import '../screens/notification/notification_page.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? selectedValue;
  final List<String>? dropdownItems;
  final ValueChanged<String?>? onDropdownChanged;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;
  final bool? showBackButton;
  final bool showNotification;
  final bool? showDropdown;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppTopBar({
    super.key,
    this.title,
    this.selectedValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.onBackPressed,
    this.onNotificationPressed,
    this.showBackButton,
    this.showNotification = true,
    this.showDropdown,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  void _handleBack(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleNotification(BuildContext context) {
    if (onNotificationPressed != null) {
      onNotificationPressed!();
    } else {
      AppNavigator.push(context, const NotificationPage());
    }
  }

  void _showDropdownMenu(BuildContext context, GlobalKey key) async {
    if (dropdownItems == null || dropdownItems!.isEmpty) return;

    final RenderBox? buttonBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final Offset position = buttonBox.localToGlobal(Offset.zero);
    final Size size = buttonBox.size;
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 6,
        overlayBox.size.width - (position.dx + size.width),
        0,
      ),
      constraints: BoxConstraints.tightFor(width: size.width),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      elevation: 4,
      items: dropdownItems!.map((String item) {
        final bool isSelected = item == selectedValue;
        return PopupMenuItem<String>(
          value: item,
          height: 44,
          child: SizedBox(
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (selected != null && onDropdownChanged != null) {
      onDropdownChanged!(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    final bool shouldShowBack = showBackButton ?? canPop;
    final GlobalKey dropdownKey = GlobalKey();

    final String displayText = selectedValue ?? title ?? 'Pilih Project / Area';
    final bool isDropdown =
        showDropdown ?? (dropdownItems != null || selectedValue != null);
    final bool isDropdownInteractive =
        dropdownItems != null && dropdownItems!.isNotEmpty;

    final Color effectiveBgColor = backgroundColor ?? Colors.transparent;
    final Color effectiveIconColor = iconColor ?? AppColors.primary;

    return Container(
      height: preferredSize.height,
      color: effectiveBgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Left: Back Button or Spacer
          if (shouldShowBack)
            IconButton(
              onPressed: () => _handleBack(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: effectiveIconColor,
                size: 26,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            )
          else
            const SizedBox(width: 40),

          const SizedBox(width: 8),

          // Middle: Dropdown, Title, or Empty Spacer
          Expanded(
            child: isDropdown
                ? GestureDetector(
                    key: dropdownKey,
                    onTap: isDropdownInteractive
                        ? () => _showDropdownMenu(context, dropdownKey)
                        : null,
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayText,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: (selectedValue == null && title == null)
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDropdownInteractive
                                ? AppColors.primary
                                : AppColors.iconColor,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  )
                : (title != null
                    ? Center(
                        child: Text(
                          title!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: (iconColor == Colors.white)
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
          ),

          const SizedBox(width: 8),

          // Right: Notification Button or Spacer
          if (showNotification)
            IconButton(
              onPressed: () => _handleNotification(context),
              icon: Icon(
                Icons.notifications_outlined,
                color: effectiveIconColor,
                size: 26,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}
