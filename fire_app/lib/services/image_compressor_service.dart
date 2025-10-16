import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';

class ImageCompressorService {
  static const int maxSizeKB = 770; // 770KB para resultar em ~1MB em Base64

  static Future<Uint8List> compressToFit(Uint8List originalBytes, {int maxAttempts = 5}) async {
    Uint8List compressedBytes = originalBytes;
    int attempt = 0;
    
    print('📏 Tamanho original: ${originalBytes.length ~/ 1024}KB');

    while (attempt < maxAttempts) {
      final currentSizeKB = compressedBytes.length ~/ 1024;
      
      if (currentSizeKB <= maxSizeKB) {
        print('✅ Compressão concluída: $currentSizeKB (tentativa ${attempt + 1})');
        return compressedBytes;
      }

      double compressionFactor = _calculateCompressionFactor(currentSizeKB);
      compressedBytes = _applyCompression(compressedBytes, compressionFactor, attempt);
      attempt++;
    }

    if (compressedBytes.length ~/ 1024 > maxSizeKB) {
      compressedBytes = _applyAggressiveCompression(compressedBytes);
    }

    final finalSizeKB = compressedBytes.length ~/ 1024;
    if (finalSizeKB > maxSizeKB) {
      throw Exception('Imagem muito grande ($finalSizeKB). Tire uma foto com menor resolução.');
    }

    return compressedBytes;
  }

  static double _calculateCompressionFactor(int currentSizeKB) {
    if (currentSizeKB > 5000) return 0.1;
    if (currentSizeKB > 2000) return 0.2;
    if (currentSizeKB > 1000) return 0.3;
    if (currentSizeKB > 500) return 0.5;
    return 0.7;
  }

  static Uint8List _applyCompression(Uint8List bytes, double factor, int attempt) {
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) throw Exception('Erro ao decodificar imagem');

    int newWidth = max((originalImage.width * factor).round(), 400);
    int newHeight = max((originalImage.height * factor).round(), 300);

    final resizedImage = img.copyResize(
      originalImage,
      width: newWidth,
      height: newHeight,
      maintainAspect: true,
    );

    int quality = max(40, 80 - (attempt * 10));
    final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

    print('🔄 Tentativa ${attempt + 1}: ${bytes.length ~/ 1024}KB → ${compressedBytes.length ~/ 1024}KB');
    return Uint8List.fromList(compressedBytes);
  }

  static Uint8List _applyAggressiveCompression(Uint8List bytes) {
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) throw Exception('Erro ao decodificar imagem');

    final resizedImage = img.copyResize(originalImage, width: 400, height: 300, maintainAspect: true);
    final compressedBytes = img.encodeJpg(resizedImage, quality: 30);

    return Uint8List.fromList(compressedBytes);
  }
}