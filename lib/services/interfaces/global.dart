abstract class ConnectionClient<T> {
  Future<void> writeMany(List<T> items);
  Future<List<T>> readMany();
}
