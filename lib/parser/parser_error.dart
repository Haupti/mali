class ParserError extends Error {
  String message;
  int lineIndex;
  ParserError(this.message, this.lineIndex);

  @override
  String toString() {
    return "PARSER ERROR at line $lineIndex: $message";
  }
}
