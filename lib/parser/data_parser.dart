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
        lines[i].substring(splitPos + 1, lines[i].length)
      );

      if (!name.startsWith('%')) {
        throw ParserError("stackpointers must start with '%'", i);
      }
      if (body.startsWith('"') && body.endsWith('"')) {
        if (result[name] != null) {
          throw ParserError("already allocated: '$name'", i);
        }
        List<Memorizable> data = [];
        for (final c in body.substring(1, body.length - 1).split("")) {
          data.add(Integer(c.codeUnitAt(0)));
        }
        result[name] = Stack(data.reversed.toList());
      } else {
        List<String> values = body.split(" ");
        List<Memorizable> data = [];
        for (final value in values) {
          double? doubl = double.tryParse(value);
          if (doubl != null) {
            data.add(Float(doubl));
            continue;
          }
          int? integer = int.tryParse(value);
          if (integer != null) {
            data.add(Integer(integer));
            continue;
          }
          Stkptr? stkptr = Stkptr.tryParse(value);
          if (stkptr != null) {
            data.add(stkptr);
            continue;
          }
          throw ParserError("no valid arguments", i);
        }
        result[name] = Stack(data.reversed.toList());
      }
    }
    return result;
  }
}
