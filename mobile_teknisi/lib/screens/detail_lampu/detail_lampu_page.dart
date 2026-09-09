import 'package:flutter/material.dart';
import '../../models/installation_model.dart';
import '../../services/auth_service.dart';
import '../../services/installation_service.dart';
import '../../services/project_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_top_bar.dart';
import '../edit_data_lampu/edit_data_lampu_page.dart';
import 'barcode_card.dart';
import 'dialog_hapus_lampu.dart';
import 'foto_dokumentasi_card.dart';
import 'informasi_lampu_card.dart';
import 'informasi_record_card.dart';
import 'lampu_header_card.dart';
import 'lokasi_card.dart';

class DetailLampuPage extends StatefulWidget {
  final int? idInstallation;
  final InstallationModel? installation;
  final int? idLamp;
  final String? lampCode;
  final String? lampType;
  final String? wattage;
  final String? status;
  final String? latitude;
  final String? longitude;
  final String? panelCode;
  final String? address;
  final String? inputMethod;
  final List<String>? photos;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;

  const DetailLampuPage({
    super.key,
    this.idInstallation,
    this.installation,
    this.idLamp,
    this.lampCode,
    this.lampType,
    this.wattage,
    this.status,
    this.latitude,
    this.longitude,
    this.panelCode,
    this.address,
    this.inputMethod,
    this.photos,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  @override
  State<DetailLampuPage> createState() => _DetailLampuPageState();
}

class _DetailLampuPageState extends State<DetailLampuPage> {
  InstallationModel? _fetchedInstallation;

  @override
  void initState() {
    super.initState();
    _loadInstallationDetailIfNeeded();
  }

  Future<void> _loadInstallationDetailIfNeeded() async {
    final id = _effectiveId;
    if (id == null) return;
    try {
      final detail = await InstallationService().getInstallationDetail(id);
      if (mounted && detail != null) {
        setState(() {
          _fetchedInstallation = detail;
        });
      }
    } catch (e) {
      debugPrint('Error loading installation detail: $e');
    }
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleLihatSemua() {
    debugPrint('Lihat Semua clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lihat Semua Foto (Aksi UI Sementara)'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  int? get _effectiveId =>
      widget.idInstallation ??
      widget.installation?.idInstallation ??
      _fetchedInstallation?.idInstallation ??
      widget.idLamp;

  String get _effectiveCode =>
      widget.installation?.lampCode ??
      _fetchedInstallation?.lampCode ??
      ((widget.lampCode != null &&
              widget.lampCode!.isNotEmpty &&
              widget.lampCode != '-')
          ? widget.lampCode!
          : '-');

  String get _effectiveType =>
      widget.installation?.lampType ??
      _fetchedInstallation?.lampType ??
      ((widget.lampType != null &&
              widget.lampType!.isNotEmpty &&
              widget.lampType != '-')
          ? widget.lampType!
          : '-');

  String _normalizeInputMethod(String? raw) {
    if (raw == null) return '-';
    final s = raw.trim();
    if (s.isEmpty || s == '-') return '-';
    final l = s.toLowerCase();
    if (l == 'realtime' || l == 'real-time') return 'Realtime';
    if (l == 'manual') return 'Manual';
    return s;
  }

  void _handleEditData() {
    final isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
            ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Project telah Selesai. Pengeditan dinonaktifkan (Read-Only).',
          ),
          backgroundColor: Color(0xFF64748B),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    debugPrint('Edit Data');
    AppNavigator.push(
      context,
      EditDataLampuPage(
        isEdit: true,
        idInstallation: _effectiveId,
        initialKodeLampu: _effectiveCode,
        initialLongitude:
            widget.installation?.longitude ?? _fetchedInstallation?.longitude ?? widget.longitude ?? '',
        initialLatitude:
            widget.installation?.latitude ?? _fetchedInstallation?.latitude ?? widget.latitude ?? '',
        initialAlamat: _fetchedInstallation?.address ?? widget.address ?? '',
        initialTipeLampu: _effectiveType,
      ),
    );
  }

  void _handleHapusData() {
    final isProjectClosed =
        ProjectService.selectedProject?.status == 'closed' ||
            ProjectService.selectedProject?.status == 'selesai';
    if (isProjectClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Project telah Selesai. Penghapusan dinonaktifkan (Read-Only).',
          ),
          backgroundColor: Color(0xFF64748B),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final code = _effectiveCode;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => DialogHapusLampu(
        lampCode: code,
        onConfirmHapus: () async {
          debugPrint('Hapus data $code (ID: $_effectiveId)');
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }
          if (_effectiveId != null) {
            await InstallationService().deleteInstallation(_effectiveId!);
          }
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = _effectiveCode;
    final type = _effectiveType;
    final currentStatus =
        widget.installation?.status ?? _fetchedInstallation?.status ?? widget.status ?? 'Tersimpan';
    final isTersimpan = currentStatus == 'Tersimpan';

    final effectivePanelCode =
        widget.installation?.panelCode ?? _fetchedInstallation?.panelCode ?? widget.panelCode;

    final rawInputMethod = widget.installation?.inputMethod ??
        _fetchedInstallation?.inputMethod ??
        widget.inputMethod;
    final effectiveInputMethod = _normalizeInputMethod(rawInputMethod);

    debugPrint('DETAIL inputMethod: ${widget.installation?.inputMethod ?? _fetchedInstallation?.inputMethod}');
    debugPrint('CARD inputMethod: $effectiveInputMethod');

    final coords = (widget.installation?.latitude != null &&
            widget.installation?.longitude != null)
        ? '${widget.installation!.latitude}, ${widget.installation!.longitude}'
        : (_fetchedInstallation?.latitude != null && _fetchedInstallation?.longitude != null)
            ? '${_fetchedInstallation!.latitude}, ${_fetchedInstallation!.longitude}'
            : (widget.latitude != null && widget.longitude != null
                ? '${widget.latitude}, ${widget.longitude}'
                : null);

    final effectivePhotos = widget.installation?.photos.isNotEmpty == true
        ? widget.installation!.photos
        : (_fetchedInstallation?.photos.isNotEmpty == true
            ? _fetchedInstallation!.photos
            : widget.photos);

    final effectiveCreatedAt = widget.installation?.createdAt != null
        ? widget.installation!.createdAt.toString()
        : (_fetchedInstallation?.createdAt != null
            ? _fetchedInstallation!.createdAt.toString()
            : widget.createdAt);

    final effectiveUpdatedAt = widget.installation?.updatedAt != null
        ? widget.installation!.updatedAt.toString()
        : (_fetchedInstallation?.updatedAt != null
            ? _fetchedInstallation!.updatedAt.toString()
            : widget.updatedAt);

    final projectName =
        ProjectService.selectedProject?.projectName ?? '-';
    final projectLocation =
        ProjectService.selectedProject?.location ?? '-';

    return Scaffold(
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

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
                      code: code,
                      isTersimpan: isTersimpan,
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
                      coordinates: coords,
                      address: widget.address,
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
                      code: code,
                      type: type,
                      panelCode: effectivePanelCode,
                      status: currentStatus,
                      inputMethod: effectiveInputMethod,
                    ),

                    const SizedBox(height: 16),

                    // Section Barcode Card
                    BarcodeCard(barcode: code),

                    const SizedBox(height: 16),

                    // Section Foto Dokumentasi Card
                    FotoDokumentasiCard(
                      photos: effectivePhotos,
                      onLihatSemua: _handleLihatSemua,
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
                      createdAt: effectiveCreatedAt,
                      updatedAt: effectiveUpdatedAt,
                      createdBy: widget.createdBy ?? AuthService.currentUser?.name,
                    ),

                    const SizedBox(height: 24),

              // Bottom Action Buttons: Edit Data & Hapus atau Banner Read-Only
              Builder(
                builder: (context) {
                  final isProjectClosed =
                      ProjectService.selectedProject?.status == 'closed' ||
                          ProjectService.selectedProject?.status == 'selesai';

                  if (isProjectClosed) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Project Selesai — Mode Baca Saja (Read-Only)',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
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
    );
  }
}
