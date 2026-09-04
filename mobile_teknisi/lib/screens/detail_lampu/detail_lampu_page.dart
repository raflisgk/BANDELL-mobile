import 'package:flutter/material.dart';
import '../../dummy/dummy_data.dart';
import '../../utils/app_colors.dart';
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
  final int? idLamp;
  final String? lampCode;
  final String? lampType;
  final String? wattage;
  final String? status;

  const DetailLampuPage({
    super.key,
    this.idLamp,
    this.lampCode,
    this.lampType,
    this.wattage,
    this.status,
  });

  @override
  State<DetailLampuPage> createState() => _DetailLampuPageState();
}

class _DetailLampuPageState extends State<DetailLampuPage> {
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

  void _handleEditData() {
    final isProjectClosed = DummyData.selectedProject?.status == 'closed' ||
        DummyData.selectedProject?.status == 'selesai';
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDataLampuPage(
          isEdit: true,
          initialKodeLampu: widget.lampCode ?? '',
          initialLongitude: '',
          initialLatitude: '',
          initialAlamat: '',
          initialTipeLampu: widget.lampType ?? '',
        ),
      ),
    );
  }

  void _handleHapusData() {
    final isProjectClosed = DummyData.selectedProject?.status == 'closed' ||
        DummyData.selectedProject?.status == 'selesai';
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

    final code = widget.lampCode ?? 'JKT-001';
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => DialogHapusLampu(
        lampCode: code,
        onConfirmHapus: () {
          debugPrint('Hapus data $code');
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = (widget.lampCode != null &&
            widget.lampCode!.isNotEmpty &&
            widget.lampCode != '-')
        ? widget.lampCode!
        : 'JKT-001';
    final type = (widget.lampType != null &&
            widget.lampType!.isNotEmpty &&
            widget.lampType != '-')
        ? widget.lampType!
        : 'LED Street Light 100W';
    final currentStatus = widget.status ?? 'Tersimpan';
    final isTersimpan = currentStatus == 'Tersimpan';

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
                      children: const [
                        Text(
                          'Project JKT',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.hintColor,
                            size: 14,
                          ),
                        ),
                        Text(
                          'Jakarta, Indonesia',
                          style: TextStyle(
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
                    const LokasiCard(),

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
                      panelCode: '123456',
                      status: 'Active',
                      inputMethod: 'Realtime',
                    ),

                    const SizedBox(height: 16),

                    // Section Barcode Card
                    const BarcodeCard(barcode: 'JKT-2025-0001'),

                    const SizedBox(height: 16),

                    // Section Foto Dokumentasi Card
                    FotoDokumentasiCard(
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
                    const InformasiRecordCard(),

                    const SizedBox(height: 24),

              // Bottom Action Buttons: Edit Data & Hapus atau Banner Read-Only
              Builder(
                builder: (context) {
                  final isProjectClosed =
                      DummyData.selectedProject?.status == 'closed' ||
                          DummyData.selectedProject?.status == 'selesai';

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
