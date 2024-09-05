class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
  @override
  String toString() {
    return 'ServerException: $message';
  }
}
