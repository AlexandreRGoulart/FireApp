import 'package:latlong2/latlong.dart';

class IncendioModel {
  final String? id;
  final String descricao;
  final String nivelRisco;
  final List<LatLng> areaPoligono;
  final String criadoEm;
  final String? criadoPor;
  final double? latitude;
  final double? longitude;
  final String? fotoUrl;

  IncendioModel({
    this.id,
    required this.descricao,
    required this.nivelRisco,
    required this.areaPoligono,
    required this.criadoEm,
    this.criadoPor,
    this.latitude,
    this.longitude,
    this.fotoUrl,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'nivelRisco': nivelRisco,
      'areaPoligono': areaPoligono
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
      'criadoEm': criadoEm,
      'criadoPor': criadoPor,
      'latitude': latitude,
      'longitude': longitude,
      'fotoUrl': fotoUrl,
    };
  }

  // Criar instância a partir de Map (Firestore)
  factory IncendioModel.fromMap(String id, Map<String, dynamic> map) {
    final areaList = map['areaPoligono'] as List<dynamic>?;
    final poligono = areaList
            ?.map((e) {
              final lat = e['latitude'] as double? ?? 0.0;
              final lng = e['longitude'] as double? ?? 0.0;
              return LatLng(lat, lng);
            })
            .toList() ??
        [];

    return IncendioModel(
      id: id,
      descricao: map['descricao'] ?? '',
      nivelRisco: map['nivelRisco'] ?? '',
      areaPoligono: poligono,
      criadoEm: map['criadoEm'] ?? '',
      criadoPor: map['criadoPor'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      fotoUrl: map['fotoUrl'],
    );
  }
}
