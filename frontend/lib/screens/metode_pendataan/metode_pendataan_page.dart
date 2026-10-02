import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/custom_feedback.dart';
import '../manual/manual_page.dart';
import '../realtime/realtime_page.dart';

class MetodePendataanPage extends StatelessWidget {
  static const String routeName = '/metode_pendataan';

  final int? idProject;
  final int? idArea;
  final String? areaName;
  final String? lampType;
  final int? lampTypeId;

  const MetodePendataanPage({
    super.key,
    this.idProject,
    this.idArea,
    this.areaName,
    this.lampType,
    this.lampTypeId,
  });

  void _handleSelectRealtime(BuildContext context) {
    final bool isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      CustomFeedback.showError(
        context,
        'Project "${ProjectService.selectedProject?.projectName}" telah Selesai. Pendataan Realtime dinonaktifkan.',
      );
      return;
    }
    debugPrint('Realtime dipilih');
    AppNavigator.push(
      context,
      RealtimePage(
        idProject: idProject,
        idArea: idArea,
        areaName: areaName,
        lampType: lampType,
        lampTypeId: lampTypeId,
      ),
    );
  }

  void _handleSelectManual(BuildContext context) {
    final bool isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      CustomFeedback.showError(
        context,
        'Project "${ProjectService.selectedProject?.projectName}" telah Selesai. Pendataan Manual dinonaktifkan.',
      );
      return;
    }
    debugPrint('Manual dipilih');
    AppNavigator.push(
      context,
      ManualPage(
        idProject: idProject,
        idArea: idArea,
        areaName: areaName,
        lampType: lampType,
        lampTypeId: lampTypeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: SafeArea(
          child: Column(
            children: [
              const AppTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.h),

                      if (isProjectClosed)
                        Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderMedium),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textMuted,
                                size: 22.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Project ini telah Selesai (Read-Only). Fitur input data Realtime dan Manual dinonaktifkan.',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBody,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Centered Title & Subtitle
                      Center(
                        child: Text(
                          'Pilih Metode Input',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Center(
                        child: Text(
                          'Bagaimana Anda ingin menambahkan data\nlampu?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                            height: 1.4,
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Card 1: Realtime
                      _buildRealtimeCard(
                        context,
                        isProjectClosed: isProjectClosed,
                      ),

                      SizedBox(height: 20.h),

                      // Card 2: Manual
                      _buildManualCard(
                        context,
                        isProjectClosed: isProjectClosed,
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeCard(
    BuildContext context, {
    required bool isProjectClosed,
  }) {
    return Opacity(
      opacity: isProjectClosed ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.realtimeBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.realtimeBorder, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleSelectRealtime(context),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Icon & Title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.realtimeBorder,
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.realtimeGreen,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Realtime',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Description
                  Text(
                    'Gunakan kamera dan GPS untuk mendapatkan data lampu secara langsung dari lokasi.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Features Checklist
                  _buildCheckFeature(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Scan Barcode',
                    color: AppColors.realtimeGreen,
                  ),
                  SizedBox(height: 6.h),
                  _buildCheckFeature(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'GPS Otomatis',
                    color: AppColors.realtimeGreen,
                  ),
                  SizedBox(height: 6.h),
                  _buildCheckFeature(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Lokasi Terkini',
                    color: AppColors.realtimeGreen,
                  ),

                  SizedBox(height: 16.h),
                  Divider(color: AppColors.realtimeBorder, height: 1.h),
                  SizedBox(height: 14.h),

                  // Card Action Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gunakan Realtime',
                        style: TextStyle(
                          color: AppColors.realtimeGreen,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.realtimeGreen,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualCard(
    BuildContext context, {
    required bool isProjectClosed,
  }) {
    return Opacity(
      opacity: isProjectClosed ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.manualBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.manualBorder, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleSelectManual(context),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Icon & Title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.manualBorder,
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          Icons.keyboard_outlined,
                          color: AppColors.manualOrange,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Manual',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Description
                  Text(
                    'Masukkan koordinat, alamat, dan informasi lampu secara manual.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Features Checklist
                  _buildCheckFeature(
                    icon: Icons.bolt_rounded,
                    label: 'Input Long / Lat',
                    color: AppColors.manualOrange,
                  ),
                  SizedBox(height: 6.h),
                  _buildCheckFeature(
                    icon: Icons.bolt_rounded,
                    label: 'Input Address',
                    color: AppColors.manualOrange,
                  ),
                  SizedBox(height: 6.h),
                  _buildCheckFeature(
                    icon: Icons.bolt_rounded,
                    label: 'Dokumentasi Manual',
                    color: AppColors.manualOrange,
                  ),

                  SizedBox(height: 16.h),
                  Divider(color: AppColors.manualBorder, height: 1.h),
                  SizedBox(height: 14.h),

                  // Card Action Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gunakan Manual',
                        style: TextStyle(
                          color: AppColors.manualOrange,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.manualOrange,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckFeature({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
