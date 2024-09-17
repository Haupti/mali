import 'package:mali/interpreter/instr_pointer_stack.dart';
import 'package:mali/interpreter/interpreter.dart';
import 'package:mali/interpreter/stack.dart';
import 'package:mali/parser/parser.dart';

class Runner {
  static int run(String code) {
    ParserResult parserResult = Parser.parse(code);
    return Interpreter.run(parserResult);
  }
  static (int, Map<String, int>, Map<String, Stack>, InstructionPointerStack) runDebug(String code) {
    ParserResult parserResult = Parser.parse(code);
    return Interpreter.runDebug(parserResult);
  }
}
