import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/installation_model.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/custom_feedback.dart';
import '../edit_data_lampu/edit_data_lampu_page.dart';
import 'detail_lampu_cards.dart';
import 'foto_dokumentasi_card.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class DetailLampuPage extends StatefulWidget {
  final int? idInstallation;
  final InstallationModel? installation;
  final int? idLamp;
  final int? idArea;
  final int? idProject;
  final String? lampCode;
  final String? lampType;
  final String? wattage;
  final String? status;
  final String? districtName;
  final String? latitude;
  final String? longitude;
  final String? panelCode;
  final String? address;
  final String? inputMethod;
  final List<String>? photos;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? noteByAdmin;

  const DetailLampuPage({
    super.key,
    this.idInstallation,
    this.installation,
    this.idLamp,
    this.idArea,
    this.idProject,
    this.lampCode,
    this.lampType,
    this.wattage,
    this.status,
    this.districtName,
    this.latitude,
    this.longitude,
    this.panelCode,
    this.address,
    this.inputMethod,
    this.photos,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.noteByAdmin,
  });

  @override
  State<DetailLampuPage> createState() => _DetailLampuPageState();
}

class _DetailLampuPageState extends State<DetailLampuPage> {
  InstallationModel? _currentInstallation;

  @override
  void initState() {
    super.initState();
    _currentInstallation = widget.installation;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    final id = _effectiveId;
    debugPrint('DETAIL REFRESH ID: $id');
    if (id == null || id <= 0) return;
    try {
      final updated = await InstallationService().getInstallationDetail(id);
      debugPrint('DETAIL REFRESH RESULT PHOTOS: ${updated?.photos}');
      if (updated != null && mounted) {
        setState(() {
          _currentInstallation = updated;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing installation detail: $e');
    }

    // Fallback: Jika berstatus Ditolak dan note_by_admin masih kosong,
    // ambil catatan penolakan dari notifikasi lokal/API
    if (mounted && _isDitolak && _effectiveNoteByAdmin == null) {
      try {
        final notifs = await NotificationService().getNotifications();
        for (final n in notifs) {
          final isMatch = (n.installationId == id ||
                  n.installation?.idInstallation == id) &&
              (n.noteByAdmin != null || n.notes != null || n.message != null);
          if (isMatch) {
            final foundNote = n.noteByAdmin ?? n.notes ?? n.message;
            if (foundNote != null && foundNote.trim().isNotEmpty && mounted) {
              setState(() {
                final base = _currentInstallation;
                if (base != null) {
                  _currentInstallation = InstallationModel(
                    idInstallation: base.idInstallation,
                    idProject: base.idProject,
                    idUser: base.idUser,
                    idArea: base.idArea,
                    districtName: base.districtName,
                    lampTypeId: base.lampTypeId,
                    idLcu: base.idLcu,
                    lampCode: base.lampCode,
                    lampType: base.lampType,
                    wattage: base.wattage,
                    status: base.status,
                    latitude: base.latitude,
                    longitude: base.longitude,
                    panelCode: base.panelCode,
                    photos: base.photos,
                    inputMethod: base.inputMethod,
                    photoUrl: base.photoUrl,
                    notes: base.notes,
                    noteByAdmin: foundNote,
                    verificationStatus: base.verificationStatus,
                    installedAt: base.installedAt,
                    createdAt: base.createdAt,
                    updatedAt: base.updatedAt,
                  );
                }
              });
              break;
            }
          }
        }
      } catch (_) {}
    }
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  InstallationModel? get _effectiveInstallation =>
      _currentInstallation ?? widget.installation;

  int? get _effectiveId =>
      widget.idInstallation ??
      _effectiveInstallation?.idInstallation ??
      widget.idLamp;

  String get _effectiveCode =>
      _effectiveInstallation?.lampCode ??
      ((widget.lampCode != null &&
              widget.lampCode!.isNotEmpty &&
              widget.lampCode != '-')
          ? widget.lampCode!
          : '-');

  String get _effectiveType =>
      _effectiveInstallation?.lampType ??
      ((widget.lampType != null &&
              widget.lampType!.isNotEmpty &&
              widget.lampType != '-')
          ? widget.lampType!
          : '-');

  String get _effectiveStatus {
    final s = _effectiveInstallation?.verificationStatus ??
        _effectiveInstallation?.status ??
        widget.status ??
        'Menunggu Verifikasi';
    if (s.trim().toLowerCase() == 'terinput') {
      return 'Terverifikasi';
    }
    return s;
  }

  bool get _isTersimpan => _effectiveStatus == 'Tersimpan';

  bool get _isVerified {
    final inst = _effectiveInstallation;
    final status = (inst?.status ?? widget.status ?? '').toLowerCase().trim();
    final verificationStatus =
        (inst?.verificationStatus ?? '').toLowerCase().trim();
    return status == 'terverifikasi' ||
        status == 'verified' ||
        status == 'terinput' ||
        verificationStatus == 'terverifikasi' ||
        verificationStatus == 'verified' ||
        verificationStatus == 'terinput';
  }

  bool get _isDitolak {
    final inst = _effectiveInstallation;
    final status = (inst?.status ?? widget.status ?? '').toLowerCase().trim();
    final verificationStatus =
        (inst?.verificationStatus ?? '').toLowerCase().trim();
    return status == 'ditolak' ||
        status == 'rejected' ||
        verificationStatus == 'ditolak' ||
        verificationStatus == 'rejected';
  }

  String? get _effectiveNoteByAdmin {
    final raw = _effectiveInstallation?.noteByAdmin ?? widget.noteByAdmin;
    if (raw != null &&
        raw.trim().isNotEmpty &&
        raw.trim() != '-' &&
        raw.trim().toLowerCase() != 'null') {
      return raw
          .replaceFirst(
            RegExp(r'^(catatan:\s*|Catatan:\s*)', caseSensitive: false),
            '',
          )
          .trim();
    }
    return null;
  }

  String? get _effectivePanelCode =>
      _effectiveInstallation?.panelCode ?? widget.panelCode;

  String get _effectiveInputMethod {
    final value = _effectiveInstallation?.inputMethod ?? widget.inputMethod;
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    final method = value.trim().toLowerCase();
    if (method == 'realtime' || method == 'real-time') {
      return 'Realtime';
    }
    if (method == 'manual') {
      return 'Manual';
    }
    return value;
  }

  int? get _resolvedAreaId =>
      _effectiveInstallation?.idArea ?? widget.idArea;

  int? get _resolvedProjectId =>
      _effectiveInstallation?.idProject ??
      widget.idProject ??
      ProjectService.selectedProject?.idProject;

  String get _effectiveDistrictName {
    final rawDistrict =
        _effectiveInstallation?.districtName ?? widget.districtName;
    if (rawDistrict != null &&
        rawDistrict.trim().isNotEmpty &&
        rawDistrict.trim() != '-') {
      return rawDistrict.trim();
    }
    return ProjectService.getAreaName(_resolvedProjectId, _resolvedAreaId) ??
        '-';
  }

  String? get _effectiveLatitude =>
      _effectiveInstallation?.latitude ?? widget.latitude;

  String? get _effectiveLongitude =>
      _effectiveInstallation?.longitude ?? widget.longitude;

  String? get _effectiveCoordinates {
    final lat = _effectiveLatitude;
    final lng = _effectiveLongitude;
    if (lat != null && lng != null) {
      return '$lat, $lng';
    }
    if (widget.latitude != null && widget.longitude != null) {
      return '${widget.latitude}, ${widget.longitude}';
    }
    return null;
  }

  List<String> get _effectivePhotos =>
      _effectiveInstallation?.photos.isNotEmpty == true
          ? _effectiveInstallation!.photos
          : (widget.photos ?? const <String>[]);

  String? get _effectiveCreatedAt =>
      _effectiveInstallation?.createdAt != null
          ? _effectiveInstallation!.createdAt.toString()
          : widget.createdAt;

  String? get _effectiveUpdatedAt =>
      _effectiveInstallation?.updatedAt != null
          ? _effectiveInstallation!.updatedAt.toString()
          : widget.updatedAt;

  DateTime? get _effectiveUpdatedAtDateTime =>
      _effectiveInstallation?.updatedAt ??
      (_effectiveUpdatedAt != null
          ? DateTime.tryParse(_effectiveUpdatedAt!)
          : null);

  void _handleEditData() async {
    if (_isVerified) {
      CustomFeedbackMessage.showError(
        context,
        'Data telah Terverifikasi. Pengeditan dinonaktifkan.',
      );
      return;
    }

    final isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      CustomFeedbackMessage.showError(
        context,
        'Proyek telah Selesai. Pengeditan dinonaktifkan.',
      );
      return;
    }

    final effectiveNotes =
        _effectiveInstallation?.notes ?? widget.address ?? '';

    debugPrint('Edit Data');
    final result = await AppNavigator.push(
      context,
      EditDataLampuPage(
        isEdit: true,
        idInstallation: _effectiveId,
        idArea: _resolvedAreaId,
        idProject: _resolvedProjectId,
        initialKodeLampu: _effectiveCode,
        initialKodePanel: _effectivePanelCode,
        initialLongitude: _effectiveLongitude ?? '',
        initialLatitude: _effectiveLatitude ?? '',
        initialAlamat: effectiveNotes,
        initialCatatan: effectiveNotes,
        initialTipeLampu: _effectiveType,
        initialPhotos: _effectivePhotos,
      ),
    );

    if (mounted) {
      if (result is InstallationModel) {
        setState(() {
          _currentInstallation = result;
        });
      }
      await _refreshDetail();
    }
  }

  void _handleHapusData() {
    if (_isVerified) {
      CustomFeedbackMessage.showError(
        context,
        'Data telah Terverifikasi. Penghapusan dinonaktifkan.',
      );
      return;
    }

    final isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
        ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      CustomFeedbackMessage.showError(
        context,
        'Proyek telah Selesai. Penghapusan dinonaktifkan.',
      );
      return;
    }

    final code = _effectiveCode;
    showDialog(
      context: context,
      barrierColor: AppColors.barrierOverlay,
      builder: (dialogContext) => DialogHapusLampu(
        lampCode: code,
        onConfirmHapus: () async {
          debugPrint('Hapus data $code (ID: $_effectiveId)');
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }
          if (_effectiveId == null) {
            if (mounted) {
              CustomFeedbackMessage.showError(context, 'Data lampu tidak ditemukan.');
            }
            return;
          }

          try {
            await InstallationService().deleteInstallation(_effectiveId!);
            if (mounted) {
              Navigator.pop(context, {'deleted': true, 'id': _effectiveId});
            }
          } catch (e) {
            debugPrint('Error deleting installation: $e');
            if (mounted) {
              final errorMsg = e
                  .toString()
                  .replaceFirst('Exception: ', '')
                  .trim();
              CustomFeedbackMessage.showError(
                context,
                errorMsg.isNotEmpty ? errorMsg : 'Data gagal dihapus',
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectName = ProjectService.selectedProject?.projectName ?? '-';
    final projectLocation = ProjectService.selectedProject?.location ?? '-';

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
              AppTopBar(
                showBackButton: true,
                showNotification: false,
                showDropdown: false,
                onBackPressed: _handleBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Card Alasan Penolakan dari Admin (Paling Atas jika status Ditolak)
                      if (_isDitolak) ...[
                        CatatanPenolakanCard(
                          note: _effectiveNoteByAdmin,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Breadcrumb Row
                      Row(
                        children: [
                          Text(
                            projectName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.hintColor,
                              size: 14,
                            ),
                          ),
                          Text(
                            projectLocation,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Card Informasional Utama (Lamp Header Card)
                      LampuHeaderCard(
                        code: _effectiveCode,
                        isTersimpan: _isTersimpan,
                        updatedAt: _effectiveUpdatedAtDateTime,
                      ),

                      const SizedBox(height: 20),

                      // Section Lokasi
                      const Text(
                        'Lokasi',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LokasiCard(
                        districtName: _effectiveDistrictName,
                        latitude: _effectiveLatitude,
                        longitude: _effectiveLongitude,
                        coordinates: _effectiveCoordinates,
                      ),

                      const SizedBox(height: 20),

                      // Section Informasi Lampu
                      const Text(
                        'Informasi Lampu',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InformasiLampuCard(
                        code: _effectiveCode,
                        type: _effectiveType,
                        panelCode: _effectivePanelCode,
                        status: _effectiveStatus,
                        inputMethod: _effectiveInputMethod,
                      ),

                      const SizedBox(height: 16),

                      // Section Barcode Card
                      BarcodeCard(barcode: _effectiveCode),

                      const SizedBox(height: 16),

                      // Section Foto Dokumentasi Card
                      FotoDokumentasiCard(
                        photos: _effectivePhotos,
                      ),

                      const SizedBox(height: 20),

                      // Section Informasi Record
                      const Text(
                        'Informasi Record',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InformasiRecordCard(
                        createdAt: _effectiveCreatedAt,
                        updatedAt: _effectiveUpdatedAt,
                        createdBy: AuthService.currentUser?.name ?? '-',
                      ),

                    const SizedBox(height: 24),

                    // Bottom Action Buttons: Edit Data & Hapus atau Banner Read-Only
                    Builder(
                      builder: (context) {
                        final isProjectClosed =
                            ProjectService.selectedProject?.status ==
                                'closed' ||
                            ProjectService.selectedProject?.status == 'selesai';

                        if (_isVerified || isProjectClosed) {
                          return const SizedBox.shrink();
                        }

                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _handleEditData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit Data',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _handleHapusData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),
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
}

class DialogHapusLampu extends StatelessWidget {
  final String lampCode;
  final VoidCallback onConfirmHapus;

  const DialogHapusLampu({
    super.key,
    required this.lampCode,
    required this.onConfirmHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upper White Section (Icon, Title, Subtitle)
            Container(
              color: AppColors.cardBackground,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  // Soft Red Circular Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.popupRedLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.deleteRed,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title
                  const Text(
                    'Hapus Data Lampu?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle with bold lamp code
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'Tindakan ini tidak dapat dibatalkan. Apakah Anda\nyakin ingin menghapus data ',
                        ),
                        TextSpan(
                          text: lampCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: '?'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lower Soft Ice/Gray Panel with Buttons
            Container(
              color: AppColors.popupPanelBackground,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Button 1: Hapus (Red)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onConfirmHapus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deleteRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Button 2: Batal (White)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

