import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/history_lamp_model.dart';
import '../models/installation_model.dart';
import '../utils/image_compress_helper.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'lamp_type_service.dart';
import 'local_cache_service.dart';
import 'offline_sync_service.dart';
import 'project_service.dart';

class InstallationService {
  /// Bersihkan seluruh cache riwayat di Storage HP
  static void clearCache() {
    LocalCacheService.clearAllHistoryCache();
  }

  /// Simpan data pemasangan lampu baru ke Laravel API dengan Fallback Offline Queue
  Future<InstallationModel> createInstallation(
    InstallationModel installation, {
    bool bypassOfflineQueue = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/installations');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(ApiService.multipartHeaders);

      final resolvedProjectId =
          (installation.idProject != null && installation.idProject! > 0)
              ? installation.idProject
              : ProjectService.selectedProject?.idProject;
      request.fields['project_id'] = resolvedProjectId?.toString() ?? '';

      final resolvedUserId =
          (installation.idUser != null && installation.idUser! > 0)
              ? installation.idUser
              : AuthService.currentUser?.idUser;
      request.fields['user_id'] = resolvedUserId?.toString() ?? '';

      int? resolvedLampTypeId =
          (installation.lampTypeId != null && installation.lampTypeId! > 0)
              ? installation.lampTypeId
              : null;
      if (resolvedLampTypeId == null && installation.lampType.isNotEmpty) {
        try {
          final types = await LampTypeService().getLampTypes();
          final match = types.firstWhere(
            (t) => t.name.toLowerCase() == installation.lampType.toLowerCase(),
          );
          resolvedLampTypeId = match.id;
        } catch (_) {}
      }
      request.fields['lamp_type_id'] = resolvedLampTypeId?.toString() ?? '';
      request.fields['district_id'] = installation.idArea.toString();
      request.fields['id_lcu'] = installation.lampCode.trim();

      final method =
          (installation.inputMethod ?? 'realtime').trim().toLowerCase();
      request.fields['input_method'] =
          method == 'real-time' ? 'realtime' : method;
      request.fields['latitude'] =
          (installation.latitude ?? '').replaceAll(',', '.');
      request.fields['longitude'] =
          (installation.longitude ?? '').replaceAll(',', '.');

      if (installation.panelCode != null &&
          installation.panelCode!.trim().isNotEmpty) {
        request.fields['code_panel'] = installation.panelCode!.trim();
      }

      if (installation.notes != null && installation.notes!.trim().isNotEmpty) {
        final noteValue = installation.notes!.trim();
        request.fields['address'] = noteValue;
        request.fields['notes'] = noteValue;
        request.fields['catatan'] = noteValue;
      }

      if (installation.installedAt != null) {
        request.fields['installed_at'] = installation.installedAt!
            .toIso8601String()
            .split('T')
            .first;
      } else if (installation.createdAt != null) {
        request.fields['installed_at'] =
            installation.createdAt!.toIso8601String().split('T').first;
      } else {
        request.fields['installed_at'] =
            DateTime.now().toIso8601String().split('T').first;
      }

      for (final photoPath in installation.photos) {
        if (photoPath.trim().isEmpty) continue;
        final file = File(photoPath);
        if (file.existsSync()) {
          final compressedPath =
              await ImageCompressHelper.compressImage(photoPath);
          final photo =
              await http.MultipartFile.fromPath('photos[]', compressedPath);
          request.files.add(photo);
        }
      }

      debugPrint('========== CREATE INSTALLATION ==========');
      debugPrint('project_id   : ${request.fields['project_id']}');
      debugPrint('user_id      : ${request.fields['user_id']}');
      debugPrint('id_lcu       : ${request.fields['id_lcu']}');
      debugPrint('bypassOffline: $bypassOfflineQueue');
      debugPrint('=========================================');

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('INSTALLATION STATUS: ${response.statusCode}');
      debugPrint('INSTALLATION RESPONSE: ${response.body}');

      if (response.statusCode == 401) {
        await ApiService.handleUnauthorized();
        throw const ApiException('Sesi login telah berakhir.', statusCode: 401);
      }

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Response server tidak valid.');
      }

      if (response.statusCode == 201 && responseData['success'] == true) {
        clearCache();
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final parsed = InstallationModel.fromJson(data);
          return parsed;
        }
        return installation;
      }

      throw Exception(
        _extractErrorMessage(responseData, 'Gagal menyimpan data pemasangan.'),
      );
    } catch (e) {
      debugPrint('createInstallation error caught: $e');
      if (e is ApiException && e.statusCode == 401) {
        rethrow;
      }
      if (!bypassOfflineQueue &&
          (e is SocketException ||
              e is TimeoutException ||
              e is http.ClientException ||
              e.toString().contains('Failed host lookup') ||
              e.toString().contains('Connection refused') ||
              e.toString().contains('timed out') ||
              e.toString().contains('Network is unreachable') ||
              e.toString().contains('Software caused connection abort'))) {
        debugPrint('Koneksi bermasalah. Menyimpan data ke ANTRIAN STORAGE HP...');
        final item =
            await OfflineSyncService().enqueueInstallation(installation);
        return item.toInstallationModel();
      }
      rethrow;
    }
  }

  /// Mengambil detail record lampu berdasarkan ID dari Laravel API
  Future<InstallationModel?> getInstallationDetail(int idInstallation) async {
    final response = await http
        .get(
          Uri.parse('${ApiService.baseUrl}/installations/$idInstallation'),
          headers: ApiService.defaultHeaders,
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('DETAIL STATUS: ${response.statusCode}');

    if (response.statusCode == 401) {
      await ApiService.handleUnauthorized();
      throw const ApiException('Sesi login telah berakhir.', statusCode: 401);
    }

    if (response.statusCode == 404) {
      return null;
    }

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if (response.statusCode == 200 && responseData['success'] == true) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        final parsed = InstallationModel.fromJson(data);
        return parsed;
      }
    }

    throw Exception(
      _extractErrorMessage(
        responseData,
        'Gagal mengambil detail data pemasangan.',
      ),
    );
  }

  /// Mengubah data lampu berdasarkan ID ke Laravel API
  Future<InstallationModel> updateInstallation(
    int idInstallation,
    InstallationModel installation,
  ) async {
    final uri = Uri.parse('${ApiService.baseUrl}/installations/$idInstallation');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(ApiService.multipartHeaders);

    request.fields['_method'] = 'PUT';

    if (installation.idProject != null && installation.idProject! > 0) {
      request.fields['project_id'] = installation.idProject.toString();
    }

    if (installation.idUser != null && installation.idUser! > 0) {
      request.fields['user_id'] = installation.idUser.toString();
    }

    if (installation.lampTypeId != null && installation.lampTypeId! > 0) {
      request.fields['lamp_type_id'] = installation.lampTypeId.toString();
    } else if (installation.lampType.isNotEmpty) {
      try {
        final types = await LampTypeService().getLampTypes();
        final match = types.firstWhere(
          (t) => t.name.toLowerCase() == installation.lampType.toLowerCase(),
        );
        request.fields['lamp_type_id'] = match.id.toString();
      } catch (_) {}
    }

    if (installation.idArea > 0 &&
        installation.idProject != null &&
        installation.idProject! > 0) {
      request.fields['district_id'] = installation.idArea.toString();
    }

    if (installation.lampCode.isNotEmpty) {
      request.fields['id_lcu'] = installation.lampCode;
    }

    if (installation.inputMethod != null &&
        installation.inputMethod!.trim().isNotEmpty) {
      request.fields['input_method'] =
          installation.inputMethod!.trim().toLowerCase();
    }

    if (installation.latitude != null &&
        installation.latitude!.trim().isNotEmpty) {
      request.fields['latitude'] = installation.latitude!.trim();
    }

    if (installation.longitude != null &&
        installation.longitude!.trim().isNotEmpty) {
      request.fields['longitude'] = installation.longitude!.trim();
    }

    if (installation.notes != null && installation.notes!.trim().isNotEmpty) {
      request.fields['address'] = installation.notes!.trim();
    }

    if (installation.panelCode != null &&
        installation.panelCode!.trim().isNotEmpty) {
      request.fields['code_panel'] = installation.panelCode!.trim();
    }

    if (installation.installedAt != null) {
      request.fields['installed_at'] = installation.installedAt!
          .toIso8601String()
          .split('T')
          .first;
    }

    request.fields['verification_status'] = 'Menunggu Verifikasi';
    request.fields['status'] = 'Menunggu Verifikasi';
    request.fields['is_verified'] = '0';

    for (final photoPath in installation.photos) {
      if (photoPath.trim().isEmpty) continue;
      final file = File(photoPath);
      if (file.existsSync()) {
        final compressedPath =
            await ImageCompressHelper.compressImage(photoPath);
        final photo =
            await http.MultipartFile.fromPath('photos[]', compressedPath);
        request.files.add(photo);
      }
    }

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      await ApiService.handleUnauthorized();
      throw const ApiException('Sesi login telah berakhir.', statusCode: 401);
    }

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      clearCache();
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return InstallationModel.fromJson(data);
      }
      return installation;
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal memperbarui data pemasangan.'),
    );
  }

  /// Menghapus data lampu berdasarkan ID dari Laravel API
  Future<bool> deleteInstallation(int idInstallation) async {
    final response = await http
        .delete(
          Uri.parse('${ApiService.baseUrl}/installations/$idInstallation'),
          headers: ApiService.defaultHeaders,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) {
      await ApiService.handleUnauthorized();
      throw const ApiException('Sesi login telah berakhir.', statusCode: 401);
    }

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if (response.statusCode == 200 && responseData['success'] == true) {
      clearCache();
      return true;
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal menghapus data pemasangan.'),
    );
  }

  /// Mengambil riwayat pendataan lampu dengan dukungan Storage HP & Network Fallback
  Future<List<HistoryLampModel>> getHistory({
    required int userId,
    required int projectId,
    String? filter,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    final sDate = startDate?.toIso8601String().split('T').first ?? '';
    final eDate = endDate?.toIso8601String().split('T').first ?? '';
    final f = filter?.trim() ?? '';

    // 1. Baca dari Storage HP jika tidak forceRefresh
    if (!forceRefresh) {
      final localJson = await LocalCacheService.getHistoryJson(
        userId: userId,
        projectId: projectId,
        filter: f,
        start: sDate,
        end: eDate,
      );
      if (localJson != null && localJson.isNotEmpty) {
        return localJson
            .map((item) =>
                HistoryLampModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    final queryParameters = <String, String>{
      'user_id': userId.toString(),
      'project_id': projectId.toString(),
    };

    if (filter != null && filter.trim().isNotEmpty) {
      final districtId = int.tryParse(filter.trim());
      if (districtId != null) {
        queryParameters['district_id'] = districtId.toString();
      }
    }

    if (startDate != null) {
      queryParameters['start_date'] = sDate;
    }

    if (endDate != null) {
      queryParameters['end_date'] = eDate;
    }

    final uri = Uri.parse('${ApiService.baseUrl}/installations')
        .replace(queryParameters: queryParameters);

    debugPrint('HISTORY URL: $uri');

    try {
      final response = await http
          .get(uri, headers: ApiService.defaultHeaders)
          .timeout(const Duration(seconds: 10));

      debugPrint('HISTORY STATUS: ${response.statusCode}');

      if (response.statusCode == 401) {
        await ApiService.handleUnauthorized();
        throw const ApiException('Sesi login telah berakhir.', statusCode: 401);
      }

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Response server tidak valid.');
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List data = responseData['data'] ?? [];
        debugPrint('HISTORY RESPONSE COUNT: ${data.length}');

        // Simpan ke Storage HP
        await LocalCacheService.saveHistoryJson(
          userId: userId,
          projectId: projectId,
          filter: f,
          start: sDate,
          end: eDate,
          data: data,
        );

        return data.map((item) {
          final map = item as Map<String, dynamic>;
          return HistoryLampModel.fromJson(map);
        }).toList();
      }

      throw Exception(
        _extractErrorMessage(
          responseData,
          'Gagal mengambil riwayat pendataan.',
        ),
      );
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        rethrow;
      }
      debugPrint('getHistory network error: $e. Using Storage HP fallback.');
      final fallbackJson = await LocalCacheService.getHistoryJson(
        userId: userId,
        projectId: projectId,
        filter: f,
        start: sDate,
        end: eDate,
      );
      if (fallbackJson != null && fallbackJson.isNotEmpty) {
        return fallbackJson
            .map((item) =>
                HistoryLampModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  /// Ekstraksi pesan error dari response Laravel (422, 403, dsb)
  static String _extractErrorMessage(
    Map<String, dynamic> responseData,
    String defaultMessage,
  ) {
    String message = defaultMessage;

    if (responseData['errors'] is Map) {
      final errors = responseData['errors'] as Map;
      if (errors.isNotEmpty) {
        final messages = <String>[];
        for (final entry in errors.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            messages.addAll(
              (entry.value as List).map(
                (e) => _translateValidationMessage(e.toString()),
              ),
            );
          } else if (entry.value != null) {
            messages.add(_translateValidationMessage(entry.value.toString()));
          }
        }
        if (messages.isNotEmpty) {
          message = messages.join('\n');
        }
      }
    } else if (responseData['message'] != null &&
        responseData['message'].toString().trim().isNotEmpty) {
      message = _translateValidationMessage(
        responseData['message'].toString().trim(),
      );
    }

    final lower = message.toLowerCase();
    if (lower.contains('sqlstate') ||
        lower.contains('sql:') ||
        lower.contains('syntax error') ||
        lower.contains('numeric value out of range') ||
        lower.contains('integrity constraint') ||
        lower.contains('connection: mysql') ||
        lower.contains('queryexception') ||
        lower.contains('database error') ||
        (lower.contains('table') && lower.contains("doesn't exist")) ||
        lower.contains('column not found')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi.';
    }

    return message;
  }

  static String _translateValidationMessage(String message) {
    final lower = message.toLowerCase().trim();

    if (lower.contains('selected district id is invalid') ||
        lower.contains('district id is invalid')) {
      return 'Area yang dipilih tidak valid.';
    }
    if (lower.contains('selected lamp type id is invalid') ||
        lower.contains('lamp type id is invalid')) {
      return 'Tipe / jenis lampu yang dipilih tidak valid.';
    }
    if (lower.contains('selected project id is invalid') ||
        lower.contains('project id is invalid')) {
      return 'Proyek yang dipilih tidak valid.';
    }
    if (lower.contains('id lcu has already been taken') ||
        lower.contains('id_lcu has already been taken')) {
      return 'Kode lampu (ID LCU) sudah digunakan.';
    }
    if (lower.contains('id lcu field is required') ||
        lower.contains('id_lcu field is required')) {
      return 'Kode lampu (ID LCU) wajib diisi.';
    }
    if (lower.contains('latitude field is required')) {
      return 'Koordinat latitude wajib diisi.';
    }
    if (lower.contains('longitude field is required')) {
      return 'Koordinat longitude wajib diisi.';
    }
    if (lower.contains('photos field is required')) {
      return 'Foto dokumentasi wajib diunggah.';
    }
    if (lower.contains('must be an image')) {
      return 'File yang diunggah harus berupa gambar.';
    }
    if (lower.contains('unauthenticated')) {
      return 'Sesi login Anda telah berakhir. Silakan masuk kembali.';
    }
    if (lower.contains('given data was invalid')) {
      return 'Data yang dimasukkan tidak valid. Silakan periksa kembali formulir Anda.';
    }

    return message;
  }
}
