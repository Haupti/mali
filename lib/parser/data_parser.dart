import 'package:mali/instruction/argument.dart';
import 'package:mali/interpreter/stack.dart';
import 'package:mali/parser/parser_error.dart';
import 'package:mali/parser/utils/parser_utils.dart';

typedef DataParserResult = Map<String, Stack>;

class DataParser {
  static DataParserResult parse(String code) {
    List<String> lines = ParserUtils.cleanLines(code);
    Map<String, Stack> result = {};

    for (int i = 0; i < lines.length; i++) {
      int splitPos = lines[i].indexOf(" ");
      var (name, body) = (
        lines[i].substring(0, splitPos),
        lines[i].substring(splitPos, lines[i].length)
      );

      if (!name.startsWith('%')) {
        throw ParserError("stackpointers must start with '%'", i);
      }
      if (body.startsWith('"') && body.endsWith('"')) {
        if (result[name] != null) {
          throw ParserError("already allocated: '$name'", i);
        }
        Stack stk = Stack.init();
        for (final c in body.substring(1, body.length - 1).split("")) {
          stk.push(Integer(c.codeUnitAt(0)));
        }
        result[name] = stk;
      } else {
        List<String> values = body.split(" ");
        Stack stk = Stack.init();
        for (final value in values) {
          double? doubl = double.tryParse(value);
          if (doubl != null) {
            stk.push(Float(doubl));
            continue;
          }
          int? integer = int.tryParse(value);
          if (integer != null) {
            stk.push(Integer(integer));
            continue;
          }
          Stkptr? stkptr = Stkptr.tryParse(value);
          if (stkptr != null) {
            stk.push(stkptr);
            continue;
          }
        }
        result[name] = stk;
      }
    }
    return result;
  }
}
