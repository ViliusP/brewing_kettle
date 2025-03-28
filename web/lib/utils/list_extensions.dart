extension ListExtensions<T> on List<T> {
  /// Returns a new list containing the last [n] elements of this list.
  /// If [n] is greater than the length of the list, returns a copy of the entire list.
  List<T> takeLast(int n) {
    if (n <= 0) {
      return []; // Return empty list for non-positive n
    }

    if (n >= length) {
      return List.from(this); // Return a copy of the whole list
    }

    return sublist(length - n);
  }
}
