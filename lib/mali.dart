import 'package:mali/interpreter/interpreter.dart';
import 'package:mali/parser/parser.dart';

int run() {
  String code = """ 
      """;
  var (instructions, labelToInstr) = Parser.parse(code);
  return Interpreter.run(instructions, labelToInstr);
}
