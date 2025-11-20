import 'package:latlong2/latlong.dart';

class CatatanModel {
  final LatLng Position;
  final String note;
  final String address;

  // Tambahan sesuai soal
  final String jenis;  // contoh: Rumah, Toko, Kantor
  final String id;     // untuk delete dan penyimpanan

  CatatanModel({
    required this.Position,
    required this.note,
    required this.address,
    required this.jenis,
    required this.id,
  });

  // Tambahan untuk simpan ke SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'lat': Position.latitude,
      'lng': Position.longitude,
      'note': note,
      'address': address,
      'jenis': jenis,
      'id': id,
    };
  }

  // Tambahan untuk baca dari SharedPreferences
  factory CatatanModel.fromMap(Map<String, dynamic> map) {
    return CatatanModel(
      Position: LatLng(map['lat'], map['lng']),
      note: map['note'],
      address: map['address'],
      jenis: map['jenis'],
      id: map['id'],
    );
  }
}
