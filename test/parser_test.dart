import 'package:mali/parser/data_parser.dart';
import 'package:test/test.dart';

void main() {
  test('data section parser works', () {
    DataParserResult dataResult = DataParser.parse("""
      %fizz "fizz"
      %buzz "buzz"
      """);
    expect(dataResult["%fizz"]!.values.map((it) => it.txt).toList(),
        ['122', '122', '105', '102']);
    expect(dataResult["%buzz"]!.values.map((it) => it.txt).toList(),
        ['122', '122', '117', '98']);
  });
}
