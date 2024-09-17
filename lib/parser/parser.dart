import 'package:mali/parser/data_parser.dart';
import 'package:mali/parser/parser_error.dart';
import 'package:mali/parser/text_parser.dart';

class ParserResult {
  DataParserResult dataResult;
  TextParserResult textResult;
  ParserResult(this.dataResult, this.textResult);
}

class Parser {
  static ParserResult parse(String code) {
    List<String> dataAndText = code.trim().split("SECTION TEXT");
    if (dataAndText.length != 2) {
      throw ParserError.vaque("expected one data section and one text section");
    }
    if (!dataAndText[0].startsWith("SECTION DATA")) {
      throw ParserError.vaque("expected data section");
    }
    DataParserResult dataResult =
        DataParser.parse(dataAndText[0].replaceFirst("SECTION DATA", ""));
    TextParserResult textResult = TextParser.parse(dataAndText[1]);
    return ParserResult(dataResult, textResult);
  }
}
