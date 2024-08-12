class Failure{
  final String message;

  Failure([this.message = "An unexpected error occurred"]);

  @override
  String toString() => message;
}