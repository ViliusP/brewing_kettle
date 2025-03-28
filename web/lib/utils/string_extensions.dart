extension StringExtensions on String {
  String toSnakeCase() {
    if (isEmpty) {
      return this;
    }

    String result = '';
    for (int i = 0; i < length; i++) {
      if (i > 0 && this[i].isUpperCase) {
        result += '_';
      }
      result += this[i].toLowerCase();
    }
    return result;
  }

  bool get isUpperCase => this == toUpperCase();
}
