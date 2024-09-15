import 'package:mali/instruction/argument.dart';
import 'package:mali/interpreter/interpreter.dart';
import 'package:mali/parser/parser.dart';

class Runner {
  static int run(String code) {
    var (instructions, labelToInstr) = Parser.parse(code);
    return Interpreter.run(instructions, labelToInstr);
  }
  static (int, Map<String, int>, Map<String, Stack>, Map<String, List<Memorizable>>, InstructionPointerStack) runDebug(String code) {
    var (instructions, labelToInstr) = Parser.parse(code);
    return Interpreter.runDebug(instructions, labelToInstr);
  }
}
