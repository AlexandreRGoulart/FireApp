import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:fire_app/model/shared_location_model.dart';
import 'package:fire_app/services/base64_service.dart'; // ADICIONAR ESTA LINHA

class FirebaseLocationService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // ATUALIZAR ESTE MÉTODO:
  Future<void> addSharedLocation(SharedLocation location, {Uint8List? imageBytes}) async {
    try {
      String? imageBase64;
      
      if (imageBytes != null) {
        print('🖼️ Processando imagem para upload...');
        imageBase64 = await Base64Service.encodeImageWithCompression(imageBytes);
        
        final base64SizeKB = Base64Service.getBase64SizeKB(imageBase64);
        print('✅ Imagem comprimida para ${base64SizeKB.toStringAsFixed(1)}KB');
      }

      final Map<String, dynamic> locationData = {
        'lat': location.lat,
        'lng': location.lng,
        'name': location.name,
        'description': location.description,
        'created_by': location.createdBy,
        'type': location.type,
        'image_base64': imageBase64 ?? '', // MUDANÇA AQUI
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      await _databaseRef.child('shared_locations').push().set(locationData);
      
      print('📍 Ponto salvo com sucesso! ${imageBase64 != null ? 'Com imagem' : 'Sem imagem'}');
        
    } catch (e) {
      print('❌ Erro ao salvar ponto: $e');
      throw Exception('Erro ao adicionar localização: $e');
    }
  }

  // O método getSharedLocations permanece IGUAL
  Stream<List<SharedLocation>> getSharedLocations() {
    return _databaseRef.child('shared_locations').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      final List<SharedLocation> locations = [];
      data.forEach((key, value) {
        final location = SharedLocation.fromMap(key.toString(), Map<String, dynamic>.from(value));
        locations.add(location);
      });
      
      return locations;
    });
  }
}