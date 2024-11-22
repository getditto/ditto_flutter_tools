import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

void copyDir(String from, String to) {
  _copyDirImpl(Directory(from), Directory(to));
}

void _copyDirImpl(Directory source, Directory destination) =>
    source.listSync(recursive: false).forEach((var entity) {
      if (entity is Directory) {
        var newDirectory =
            Directory(join(destination.absolute.path, basename(entity.path)));
        newDirectory.createSync();

        _copyDirImpl(entity.absolute, newDirectory);
      } else if (entity is File) {
        entity.copySync(join(destination.path, basename(entity.path)));
      }
    });

Future<String> tempDir() async {
  final dir = await getTemporaryDirectory();
  return dir.path;
}
