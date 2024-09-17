class ParserError extends Error {
  String message;
  int? lineIndex;
  ParserError(this.message, this.lineIndex);
  ParserError.vaque(this.message) : lineIndex = null;

  @override
  String toString() {
    if (lineIndex == null) {
      return "PARSER ERROR: $message";
    }
    return "PARSER ERROR at line $lineIndex: $message";
  }
}
