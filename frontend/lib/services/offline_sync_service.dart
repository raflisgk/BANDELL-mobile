import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_lamp_model.dart';
import '../models/installation_model.dart';
import 'installation_service.dart';
import 'local_cache_service.dart';

class OfflineInstallationItem {
  final String localId;
  final int userId;
  final int projectId;
  final int idArea;
  final String districtName;
  final int? lampTypeId;
  final String lampType;
  final String lampCode;
  final String? panelCode;
  final String? inputMethod;
  final String? latitude;
  final String? longitude;
  final String? address;
  final DateTime? installedAt;
  final DateTime createdAt;
  final List<String> localPhotoPaths;
  bool isSyncing;
  String? syncError;

  OfflineInstallationItem({
    required this.localId,
    required this.userId,
    required this.projectId,
    required this.idArea,
    required this.districtName,
    this.lampTypeId,
    required this.lampType,
    required this.lampCode,
    this.panelCode,
    this.inputMethod,
    this.latitude,
    this.longitude,
    this.address,
    this.installedAt,
    required this.createdAt,
    required this.localPhotoPaths,
    this.isSyncing = false,
    this.syncError,
  });

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'userId': userId,
        'projectId': projectId,
        'idArea': idArea,
        'districtName': districtName,
        'lampTypeId': lampTypeId,
        'lampType': lampType,
        'lampCode': lampCode,
        'panelCode': panelCode,
        'inputMethod': inputMethod,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'installedAt': installedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'localPhotoPaths': localPhotoPaths,
      };

  factory OfflineInstallationItem.fromJson(Map<String, dynamic> json) {
    return OfflineInstallationItem(
      localId: json['localId']?.toString() ?? '',
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      projectId: json['projectId'] is int
          ? json['projectId']
          : int.tryParse(json['projectId']?.toString() ?? '0') ?? 0,
      idArea: json['idArea'] is int
          ? json['idArea']
          : int.tryParse(json['idArea']?.toString() ?? '0') ?? 0,
      districtName: json['districtName']?.toString() ?? '',
      lampTypeId: json['lampTypeId'] is int
          ? json['lampTypeId']
          : int.tryParse(json['lampTypeId']?.toString() ?? ''),
      lampType: json['lampType']?.toString() ?? '',
      lampCode: json['lampCode']?.toString() ?? '',
      panelCode: json['panelCode']?.toString(),
      inputMethod: json['inputMethod']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      address: json['address']?.toString(),
      installedAt: json['installedAt'] != null
          ? DateTime.tryParse(json['installedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      localPhotoPaths: json['localPhotoPaths'] is List
          ? (json['localPhotoPaths'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  InstallationModel toInstallationModel() {
    return InstallationModel(
      idInstallation: 0,
      idProject: projectId,
      idUser: userId,
      idArea: idArea,
      districtName: districtName,
      lampTypeId: lampTypeId,
      lampType: lampType,
      idLcu: lampCode,
      lampCode: lampCode,
      panelCode: panelCode,
      inputMethod: inputMethod,
      latitude: latitude,
      longitude: longitude,
      notes: address,
      status: 'Menunggu Jaringan',
      verificationStatus: 'Menunggu Jaringan',
      photos: localPhotoPaths,
      installedAt: installedAt,
      createdAt: createdAt,
    );
  }

  HistoryLampModel toHistoryLampModel() {
    final lat = latitude;
    final lng = longitude;
    final coordStr =
        (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty)
            ? '$lat, $lng'
            : '';
    return HistoryLampModel(
      idHistory: null,
      userId: userId,
      projectId: projectId,
      areaId: idArea,
      districtName: districtName,
      idLcu: lampCode,
      kode: lampCode,
      jenis: lampType,
      status: 'Menunggu Jaringan',
      isVerified: false,
      lokasi: address ?? '-',
      koordinat: coordStr,
      latitude: lat,
      longitude: lng,
      fotoCount: '${localPhotoPaths.length} Foto Lampu',
      waktu: createdAt.toIso8601String(),
      tanggal: installedAt ?? createdAt,
      installedAt: installedAt,
      createdAt: createdAt,
      inputMethod: inputMethod,
      panelCode: panelCode,
      installation: toInstallationModel(),
    );
  }
}

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  static const String _keyOfflineQueue = 'offline_upload_queue';
  final ValueNotifier<int> pendingCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;

  Future<void> init() async {
    await updatePendingCount();
    _startListeners();
  }

  void _startListeners() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        debugPrint('Connectivity changed to Online. Triggering sync...');
        syncPendingQueue();
      }
    });

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncPendingQueue();
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
  }

  static Future<SharedPreferences> _getPrefs() async =>
      SharedPreferences.getInstance();

  static List<OfflineInstallationItem> getQueueSync({
    int? userId,
    int? projectId,
  }) {
    try {
      final prefs = LocalCacheService.prefs;
      if (prefs == null) return [];
      final raw = prefs.getString(_keyOfflineQueue);
      if (raw == null || raw.isEmpty) return [];

      final List decoded = jsonDecode(raw);
      var items = decoded
          .map((e) =>
              OfflineInstallationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (userId != null && userId > 0) {
        items = items.where((i) => i.userId == userId).toList();
      }
      if (projectId != null && projectId > 0) {
        items = items.where((i) => i.projectId == projectId).toList();
      }

      return items;
    } catch (e) {
      debugPrint('OfflineSyncService getQueueSync error: $e');
      return [];
    }
  }

  Future<List<OfflineInstallationItem>> getQueue({
    int? userId,
    int? projectId,
  }) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_keyOfflineQueue);
      if (raw == null || raw.isEmpty) return [];

      final List decoded = jsonDecode(raw);
      var items = decoded
          .map((e) =>
              OfflineInstallationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (userId != null) {
        items = items.where((i) => i.userId == userId).toList();
      }
      if (projectId != null) {
        items = items.where((i) => i.projectId == projectId).toList();
      }

      return items;
    } catch (e) {
      debugPrint('OfflineSyncService getQueue error: $e');
      return [];
    }
  }

  Future<void> updatePendingCount() async {
    final queue = await getQueue();
    pendingCountNotifier.value = queue.length;
  }

  /// Simpan data pemasangan ke antrean lokal HP
  Future<OfflineInstallationItem> enqueueInstallation(
    InstallationModel installation,
  ) async {
    final prefs = await _getPrefs();
    final localId = 'draft_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Simpan foto ke folder permanen aplikasi
    final permanentPhotos = <String>[];
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final offlinePhotoDir = Directory('${docDir.path}/offline_photos');
      if (!await offlinePhotoDir.exists()) {
        await offlinePhotoDir.create(recursive: true);
      }

      for (int i = 0; i < installation.photos.length; i++) {
        final srcPath = installation.photos[i];
        final srcFile = File(srcPath);
        if (await srcFile.exists()) {
          final ext = srcPath.split('.').last;
          final dstPath = '${offlinePhotoDir.path}/${localId}_$i.$ext';
          await srcFile.copy(dstPath);
          permanentPhotos.add(dstPath);
        }
      }
    } catch (e) {
      debugPrint('Error saving offline photos: $e');
      permanentPhotos.addAll(installation.photos);
    }

    final item = OfflineInstallationItem(
      localId: localId,
      userId: installation.idUser ?? 0,
      projectId: installation.idProject ?? 0,
      idArea: installation.idArea,
      districtName: installation.districtName ?? '',
      lampTypeId: installation.lampTypeId,
      lampType: installation.lampType,
      lampCode: installation.lampCode,
      panelCode: installation.panelCode,
      inputMethod: installation.inputMethod,
      latitude: installation.latitude,
      longitude: installation.longitude,
      address: installation.notes,
      installedAt: installation.installedAt,
      createdAt: DateTime.now(),
      localPhotoPaths: permanentPhotos,
    );

    final queue = await getQueue();
    queue.insert(0, item);

    final jsonStr = jsonEncode(queue.map((e) => e.toJson()).toList());
    await prefs.setString(_keyOfflineQueue, jsonStr);
    await updatePendingCount();

    debugPrint('OFFLINE QUEUE ADDED: $localId (Total: ${queue.length})');
    return item;
  }

  /// Hapus item antrean dan bersihkan file foto lokal dari storage HP
  Future<void> removeQueueItem(String localId) async {
    final prefs = await _getPrefs();
    final queue = await getQueue();

    final matchIndex = queue.indexWhere((i) => i.localId == localId);
    if (matchIndex != -1) {
      final item = queue[matchIndex];
      // Hapus file foto dari disk HP
      for (final p in item.localPhotoPaths) {
        try {
          final f = File(p);
          if (await f.exists()) {
            await f.delete();
          }
        } catch (_) {}
      }
      queue.removeAt(matchIndex);

      final jsonStr = jsonEncode(queue.map((e) => e.toJson()).toList());
      await prefs.setString(_keyOfflineQueue, jsonStr);
      await updatePendingCount();
    }
  }

  /// Jalankan proses sinkronisasi antrean ke server backend
  Future<int> syncPendingQueue() async {
    if (isSyncingNotifier.value) return 0;

    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    if (!isOnline) {
      debugPrint('OfflineSync: Device is offline. Skipping sync.');
      return 0;
    }

    final queue = await getQueue();
    if (queue.isEmpty) return 0;

    isSyncingNotifier.value = true;
    int successCount = 0;

    debugPrint('STARTING OFFLINE SYNC for ${queue.length} items...');

    for (final item in List<OfflineInstallationItem>.from(queue)) {
      try {
        final model = item.toInstallationModel();
        await InstallationService()
            .createInstallation(model, bypassOfflineQueue: true);

        // Sukses diunggah ke backend -> hapus dari storage HP
        await removeQueueItem(item.localId);
        successCount++;
        debugPrint('OFFLINE SYNC SUCCESS for: ${item.lampCode}');
      } catch (e) {
        debugPrint('OFFLINE SYNC FAILED for ${item.lampCode}: $e');
        break;
      }
    }

    isSyncingNotifier.value = false;
    await updatePendingCount();
    return successCount;
  }
}
