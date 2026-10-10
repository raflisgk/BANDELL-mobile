import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../utils/app_colors.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavbar({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(36.w, 0, 36.w, 20.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: GNav(
              selectedIndex: currentIndex.clamp(0, 2),
              onTabChange: (index) => onTap?.call(index),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              rippleColor: AppColors.primary.withValues(alpha: 0.1),
              hoverColor: AppColors.primary.withValues(alpha: 0.05),
              haptic: true,
              tabBorderRadius: 20.r,
              gap: 8.w,
              color: AppColors.textMuted,
              activeColor: AppColors.primary,
              iconSize: 22.r,
              tabBackgroundColor: AppColors.primary.withValues(alpha: 0.10),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              textStyle: TextStyle(
                color: AppColors.primary,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                GButton(icon: Icons.cases_rounded, text: 'Proyek'),
                GButton(icon: Icons.lightbulb_rounded, text: 'Riwayat'),
                GButton(icon: Icons.person_rounded, text: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
