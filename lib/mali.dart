import 'package:mali/parser/parser.dart';

int run() {
  String code = """ 
      """;
  var instructions = Parser.parse(code);
  Interpreter.run(instructions);
}
