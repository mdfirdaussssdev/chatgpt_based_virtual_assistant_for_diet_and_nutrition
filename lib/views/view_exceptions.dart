class EmptyFieldViewException implements Exception {
  final String message;

  EmptyFieldViewException([this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'EmptyFieldViewException';
    }
    return 'EmptyFieldViewException: $message';
  }
}

class InvalidFieldViewException implements Exception {}
