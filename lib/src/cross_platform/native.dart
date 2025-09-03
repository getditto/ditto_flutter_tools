import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

List<(String, int)> directorySizeSummary(String directory) =>
    Directory(directory).listSync().map((entity) {
      return (basename(entity.path), _sizeOfEntity(entity));
    }).toList();

int _sizeOfEntity(FileSystemEntity entity) {
  final stat = entity.statSync();
  if (stat.type == FileSystemEntityType.directory) {
    return Directory(entity.path)
        .listSync()
        .map(_sizeOfEntity)
        .fold(0, (a, b) => a + b);
  }

  return stat.size;
}

/// Parameters for ZIP creation in isolate
class _ZipParams {
  final String sourceDir;
  final String outputPath;
  
  _ZipParams(this.sourceDir, this.outputPath);
}

/// Creates ZIP file in background isolate to prevent UI blocking
void _createZipFile(_ZipParams params) {
  final encoder = ZipFileEncoder();
  encoder.create(params.outputPath);
  encoder.addDirectory(Directory(params.sourceDir), includeDirName: false);
  encoder.close();
}

/// Creates a temporary ZIP file for sharing (doesn't copy to destination)
Future<String> createTempZipForSharing(String sourceDir) async {
  try {
    // Verify source directory exists
    final sourceDirectory = Directory(sourceDir);
    if (!await sourceDirectory.exists()) {
      throw Exception('Source directory does not exist: $sourceDir');
    }
    
    final tempDir = Directory.systemTemp;
    final tempZipPath = join(tempDir.path, 'ditto-export-${DateTime.now().millisecondsSinceEpoch}.zip');
    
    // Create zip file in background isolate to avoid blocking UI
    await compute(_createZipFile, _ZipParams(sourceDir, tempZipPath));
    
    // Verify ZIP file was created successfully
    final zipFile = File(tempZipPath);
    if (!await zipFile.exists()) {
      throw Exception('Failed to create ZIP file');
    }
    
    final zipSize = await zipFile.length();
    if (zipSize == 0) {
      throw Exception('Created ZIP file is empty');
    }
    
    return tempZipPath;
  } catch (e) {
    throw Exception('Failed to create database export: ${e.toString()}');
  }
}

/// Safely deletes a temporary file
Future<void> deleteTemporaryFile(String filePath) async {
  try {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    // Ignore deletion errors - temp files will be cleaned up by system eventually
  }
}
