import '../dummy/dummy_data.dart';
import '../models/lamp_type_model.dart';

class LampTypeService {
  /// Mengambil daftar semua jenis lampu dari Laravel API
  Future<List<LampTypeModel>> getLampTypes() async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/lamp-types)
    await Future.delayed(const Duration(milliseconds: 300));
    return DummyData.lampTypes
        .map((lt) => LampTypeModel(
              id: lt.id,
              name: lt.name,
              description: lt.description,
            ))
        .toList();
  }
}
