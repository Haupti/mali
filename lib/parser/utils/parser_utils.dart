class ParserUtils {
  static List<String> cleanLines(String code) {
    List<String> linesWithComments =
        code.split("\n").map((it) => it.trim()).toList();

    List<String> lineAndContent = [];

    String line;
    for (int i = 0; i < linesWithComments.length; i++) {
      line = linesWithComments[i];
      if (line.isEmpty) {
        continue;
      }
      if (!line.startsWith(";")) {
        int commentStart = line.indexOf(";");
        if (commentStart == -1) {
          lineAndContent.add(line);
        } else {
          lineAndContent.add(line.substring(0, commentStart));
        }
      }
    }
    return lineAndContent;
  }
}
