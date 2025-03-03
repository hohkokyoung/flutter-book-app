extension GeneralExtensions<T> on T? {
  bool isEmpty() {
    if (this == null) return true;

    if (this is String) {
      return (this as String).isEmpty;
    } else if (this is int) {
      return this == 0;
    } else if (this is double) {
      return this == 0.0;
    } else if (this is Iterable) {
      return (this as Iterable).isEmpty;
    } else if (this is Map) {
      return (this as Map).isEmpty;
    }

    // Add more cases as needed
    return false;
  }

  bool isNotEmpty() => !isEmpty();
}