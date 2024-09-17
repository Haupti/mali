
class RuntimeError extends Error {
  String message;
  RuntimeError(this.message);
  @override
  String toString() {
    return "RUNTIME ERROR: $message";
  }
}
