import 'package:latlong2/latlong.dart';

class SharedLocation {
  final String id;
  final double lat;
  final double lng;
  final String name;
  final String description;
  final String createdBy;
  final String type;
  final String imageBase64; // MUDANÇA AQUI
  final DateTime createdAt;

  SharedLocation({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.type,
    this.imageBase64 = '', // MUDANÇA AQUI
    required this.createdAt,
  });

  factory SharedLocation.fromMap(String id, Map<String, dynamic> map) {
    return SharedLocation(
      id: id,
      lat: map['lat'] ?? 0.0,
      lng: map['lng'] ?? 0.0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['created_by'] ?? '',
      type: map['type'] ?? 'fire',
      imageBase64: map['image_base64'] ?? '', // MUDANÇA AQUI
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'type': type,
      'image_base64': imageBase64, // MUDANÇA AQUI
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  LatLng toLatLng() {
    return LatLng(lat, lng);
  }

  // NOVO MÉTODO: verifica se tem imagem
  bool get hasImage => imageBase64.isNotEmpty;
}