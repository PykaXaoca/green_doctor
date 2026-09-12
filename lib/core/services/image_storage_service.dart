import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Сервис для сохранения изображений (фото растений, пакетиков семян) локально.
///
/// Копирует выбранное пользователем изображение в папку приложения,
/// сжимает до max 1024px по длинной стороне и сохраняет как JPEG (качество 85).
class ImageStorageService {
  static const _uuid = Uuid();

  /// Сохраняет изображение и возвращает путь к сохранённому файлу.
  ///
  /// [sourceFile] — файл, выбранный пользователем (из image_picker).
  /// [prefix] — префикс для имени файла (например, 'plant' или 'seed').
  Future<String> saveImage(File sourceFile, {String prefix = 'img'}) async {
    // 1. Куда сохраняем
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docsDir.path, 'pocket_botanist_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 2. Сжатие
    final bytes = await sourceFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception(
        'Не удалось декодировать изображение: ${sourceFile.path}',
      );
    }

    // Ограничиваем максимальную сторону до 1024px
    final resized = _resizeMax(decoded, 1024);

    // 3. Сохранение
    final fileName = '${prefix}_${_uuid.v4()}.jpg';
    final targetPath = p.join(imagesDir.path, fileName);
    final jpg = img.encodeJpg(resized, quality: 85);
    await File(targetPath).writeAsBytes(jpg);

    return targetPath;
  }

  /// Удаляет изображение по пути (если оно внутри нашей папки).
  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  img.Image _resizeMax(img.Image source, int maxSide) {
    final longSide = source.width > source.height
        ? source.width
        : source.height;
    if (longSide <= maxSide) return source;

    final scale = maxSide / longSide;
    final newWidth = (source.width * scale).round();
    final newHeight = (source.height * scale).round();
    return img.copyResize(source, width: newWidth, height: newHeight);
  }
}
