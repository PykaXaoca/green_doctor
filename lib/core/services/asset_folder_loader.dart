import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Утилиты для загрузки всех .json-файлов из папки ассетов.
///
/// Использует [AssetManifest] (Flutter 3.7+) — не требует
/// прописывать каждый файл в pubspec.yaml отдельной строкой,
/// достаточно указать папку в разделе `flutter: assets:`.
Future<Map<String, String>> loadJsonAssetsInFolder(String folder) async {
  final result = <String, String>{};
  final normalized = folder.endsWith('/') ? folder : '$folder/';

  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  for (final path in manifest.listAssets()) {
    if (!path.startsWith(normalized)) continue;
    if (!path.endsWith('.json')) continue;

    try {
      result[path] = await rootBundle.loadString(path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AssetFolderLoader] Не удалось прочитать $path: $e');
      }
    }
  }

  return result;
}

/// Возвращает `Map<id, объект>` для папки, где каждый файл — один
/// объект, а `id` берётся:
///   1. из поля `id` объекта, если оно есть;
///   2. иначе — из имени файла без `.json`.
///
/// При несовпадении `id` объекта и имени файла — пишет
/// `debugPrint` и берёт **id из объекта** (решение «1 -> C»).
Future<Map<String, Map<String, dynamic>>> loadJsonObjectsByIdFromFolder(
  String folder,
) async {
  final files = await loadJsonAssetsInFolder(folder);
  final result = <String, Map<String, dynamic>>{};

  for (final entry in files.entries) {
    final fileName = entry.key.split('/').last;
    final fileNameWithoutExt = fileName.endsWith('.json')
        ? fileName.substring(0, fileName.length - 5)
        : fileName;

    try {
      final decoded = jsonDecode(entry.value);
      if (decoded is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint(
            '[AssetFolderLoader] ${entry.key}: ожидался объект, '
            'получено ${decoded.runtimeType}',
          );
        }
        continue;
      }

      final objectId = decoded['id'];
      final resolvedId = (objectId is String && objectId.isNotEmpty)
          ? objectId
          : fileNameWithoutExt;

      if (objectId is String &&
          objectId.isNotEmpty &&
          objectId != fileNameWithoutExt) {
        if (kDebugMode) {
          debugPrint(
            '[AssetFolderLoader] ${entry.key}: '
            'id в объекте ("$objectId") != имени файла '
            '("$fileNameWithoutExt")',
          );
        }
      }

      result[resolvedId] = decoded;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AssetFolderLoader] ${entry.key}: $e');
      }
    }
  }

  return result;
}

/// Для `seasonal_care`: объекты **не содержат** поле `id`,
/// ключом является имя файла без `.json`.
Future<Map<String, Map<String, dynamic>>> loadJsonObjectsByFileName(
  String folder,
) async {
  final files = await loadJsonAssetsInFolder(folder);
  final result = <String, Map<String, dynamic>>{};

  for (final entry in files.entries) {
    final fileName = entry.key.split('/').last;
    final id = fileName.endsWith('.json')
        ? fileName.substring(0, fileName.length - 5)
        : fileName;

    try {
      final decoded = jsonDecode(entry.value);
      if (decoded is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint(
            '[AssetFolderLoader] ${entry.key}: ожидался объект, '
            'получено ${decoded.runtimeType}',
          );
        }
        continue;
      }
      result[id] = decoded;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AssetFolderLoader] ${entry.key}: $e');
      }
    }
  }

  return result;
}
