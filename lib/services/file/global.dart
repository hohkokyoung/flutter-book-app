import 'package:booksum/services/interfaces/global.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class FileConnectionClient<T> implements ConnectionClient<T> {
  final String filePath;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  FileConnectionClient(this.filePath,
      {required this.fromMap, required this.toMap});

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getLocalFile() async {
    final path = await localPath;
    return File('$path/$filePath}');
  }

  @override
  Future<void> writeMany(List<T> items) async {
    final file = await getLocalFile();
    String jsonString = jsonEncode(items.map(toMap).toList());
    await file.writeAsString(jsonString);
  }

  @override
  Future<List<T>> readMany() async {
    try {
      final file = await getLocalFile();
      if (!await file.exists()) {
        return [];
      }
      String jsonString = await file.readAsString();
      return (jsonDecode(jsonString) as List)
          .map((item) => fromMap(item))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
