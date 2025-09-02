import 'dart:io';

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

String copyDir(String from, String to) {
  final destDir = Directory(join(to, 'ditto-export-${DateTime.now().millisecondsSinceEpoch}'));
  destDir.createSync(recursive: true);
  _copyDirImpl(Directory(from), destDir);
  return destDir.path;
}

void _copyDirImpl(Directory source, Directory destination) =>
    source.listSync(recursive: false).forEach((var entity) {
      final entityName = basename(entity.path);
      
      // Skip lock files and system files that might be in use
      if (entityName.startsWith('__ditto_lock') || 
          entityName.startsWith('.') ||
          entityName == 'lock.mdb') {
        return;
      }
      
      if (entity is Directory) {
        var newDirectory =
            Directory(join(destination.absolute.path, entityName));
        newDirectory.createSync();

        _copyDirImpl(entity.absolute, newDirectory);
      } else if (entity is File) {
        }
      }
    });
