import 'dart:convert';
import 'dart:typed_data';
import 'image_compressor_service.dart';

class Base64Service {
  static Future<String> encodeImageWithCompression(Uint8List imageBytes) async {
    try {
      print('🔧 Iniciando compressão da imagem...');
      
      final compressedBytes = await ImageCompressorService.compressToFit(imageBytes);
      final base64String = base64Encode(compressedBytes);
      
      // Verifica se não excede 1MB (1024*1024 caracteres)
      if (base64String.length > 1024 * 1024) {
        throw Exception('Imagem muito grande após compressão.');
      }

      final originalSizeKB = imageBytes.length ~/ 1024;
      final finalSizeKB = compressedBytes.length ~/ 1024;
      
      print('🎉 Compressão: ${originalSizeKB}KB → ${finalSizeKB}KB');
      return base64String;
    } catch (e) {
      throw Exception('Falha na compressão: $e');
    }
  }

  static Uint8List decodeImage(String base64String) {
    return base64Decode(base64String);
  }

  static double getBase64SizeKB(String base64String) {
    return base64String.length / 1024;
  }
}