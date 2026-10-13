class Failure {
  final String message;
  final String? code;

  const Failure(
      this.message, {
        this.code,
      });

  @override
  String toString() {
    return message;
  }
}