
import 'package:booksum/services/api/global.dart';
import 'package:booksum/services/file/global.dart';
import 'package:booksum/services/interfaces/global.dart';

class ConnectionClientFactory {
  static ConnectionClient<T> createConnectionClient<T>({
    required bool useApi,
    required String pathOrUrl,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
  }) {
    return useApi
        ? ApiConnectionClient<T>(pathOrUrl, fromMap: fromMap, toMap: toMap)
        : FileConnectionClient<T>(pathOrUrl, fromMap: fromMap, toMap: toMap);
  }
}

