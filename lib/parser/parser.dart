import 'package:mali/instruction/argument.dart';
import 'package:mali/instruction/instruction.dart';

typedef ParserResult = (
  List<Instruction> instructions,
  Map<String, int> labelInstrPointers
);

class Parser {
  static ParserResult parse(String code) {
    List<String> linesAndContents = _cleanLines(code);
    Map<String, int> labelInstrPointers = {};

    List<Instruction Function(Map<String, int>)> instructions = [];
    List<String> parts;
    for (final (linenr, line) in linesAndContents.indexed) {
      parts = line.split(" ");
      switch (parts) {
        case ['REMH', String arg]:
          instructions.add((labels) => REMHInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, arg)));
        case ['REML', String arg]:
          instructions.add((labels) => REMLInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, arg)));
        case ['STOREH', String fst, String snd]:
          instructions.add((labels) => STOREHInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, fst),
              _ArgumentParser.verifiedMemorypointer(linenr, snd)));
        case ['STORE', String fst, String snd]:
          instructions.add((labels) => STOREInstruction(
              _ArgumentParser.verifiedStackIntFloat(linenr, fst),
              _ArgumentParser.verifiedMemorypointer(linenr, snd)));
        case ['LOADL', String memptr, String stkptr]:
          instructions.add((labels) => LOADLInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr),
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['LOADH', String memptr, String stkptr]:
          instructions.add((labels) => LOADHInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr),
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['LOAD', String memptr, String pos, String stkptr]:
          instructions.add((labels) => LOADInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr),
              _ArgumentParser.verifiedInteger(linenr, pos).value,
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['JMP0', String stkptr, String label]:
          instructions.add((labels) => JMP0Instruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr),
              _ArgumentParser.verifiedLabel(linenr, labels, label)));
        case ['JMP1', String stkptr, String label]:
          instructions.add((labels) => JMP1Instruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr),
              _ArgumentParser.verifiedLabel(linenr, labels, label)));
        case ['EXIT', String arg]:
          instructions.add((labels) =>
              EXITInstruction(_ArgumentParser.verifiedStackOrInt(linenr, arg)));
        case ['LABEL', String labelraw]:
          Label label = _ArgumentParser.verifiedNewLabel(
              linenr, labelInstrPointers, labelraw);
          labelInstrPointers[label.value] = linenr;
          instructions.add((_) => LABELInstruction(label));
        case ['GOTO', String labelraw]:
          instructions.add((labels) => GOTOInstruction(
              _ArgumentParser.verifiedLabel(linenr, labels, labelraw)));
        case ['CALL', String label]:
          instructions.add((labels) => CALLInstruction(
              _ArgumentParser.verifiedLabel(linenr, labels, label)));
        case ['ADD', String stkptr]:
          instructions.add((labels) => ADDInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['SUB', String stkptr]:
          instructions.add((labels) => SUBInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['MUL', String stkptr]:
          instructions.add((labels) => MULInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['DIV', String stkptr]:
          instructions.add((labels) => DIVInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['MOD', String stkptr]:
          instructions.add((labels) => MODInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['AND', String stkptr]:
          instructions.add((labels) => ANDInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['OR', String stkptr]:
          instructions.add((labels) => ORInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['POP', String stkptr]:
          instructions.add((labels) => POPInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['EQ', String stkptr]:
          instructions.add((labels) => EQInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['OUT', String memptr]:
          instructions.add((labels) => OUTInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr)));
        case ['ALLOC', String memptr]:
          instructions.add((labels) => ALLOCInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr)));
        case ['FREE', String memptr]:
          instructions.add((labels) => FREEInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr)));
        case ['RET']:
          instructions.add((labels) => RETInstruction());
        case ['EQV', String stkptr, String value]:
          instructions.add((labels) => EQVInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr),
              _ArgumentParser.verifiedNumber(linenr, value)));
        case ['MOV', String src, String dest]:
          instructions.add((labels) => MOVInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, src),
              _ArgumentParser.verifiedStackpointer(linenr, dest)));
        case ['CPY', String src, String dest]:
          instructions.add((labels) => CPYInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, src),
              _ArgumentParser.verifiedStackpointer(linenr, dest)));
        case ['PUSH', String value, String stkptr]:
          instructions.add((labels) => PUSHInstruction(
              _ArgumentParser.verifiedNumber(linenr, value),
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        default:
          throw ParserError("invalid instruction or usage: $line", linenr);
      }
    }
    return (
      instructions.map((it) => it(labelInstrPointers)).toList(),
      labelInstrPointers
    );
  }

  static List<String> _cleanLines(String code) {
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

class _ArgumentParser {
  static Label verifiedNewLabel(
      int index, Map<String, int> labelInstrPointers, String txt) {
    if (txt == "") {
      throw ParserError("label missing", index);
    }
    int codeVal = txt.codeUnitAt(0);
    if (codeVal < 97 || codeVal > 122) {
      // a - z
      throw ParserError("labels must start with lowercase latin letter", index);
    }
    var res = labelInstrPointers[txt];
    if (res != null) {
      throw ParserError("label already defined", index);
    }
    return Label(txt);
  }

  static Label verifiedLabel(
      int index, Map<String, int> labelInstrPointers, String txt) {
    if (txt == "") {
      throw ParserError("label missing", index);
    }
    int codeVal = txt.codeUnitAt(0);
    if (codeVal < 97 || codeVal > 122) {
      // a - z
      throw ParserError("labels must start with lowercase latin letter", index);
    }
    var res = labelInstrPointers[txt];
    if (res == null) {
      throw ParserError("no such label defined", index);
    }
    return Label(txt);
  }

  static Stkptr verifiedStackpointer(int index, String txt) {
    if (txt.length < 2) {
      throw ParserError("stkptr missing", index);
    }
    int codeVal = txt.codeUnitAt(1);
    if (codeVal < 97 || codeVal > 122) {
      // a - z
      throw ParserError(
          "stackpointer names must start with lowercase latin letter", index);
    }
    if (txt[0] != "\$") {
      throw ParserError("stackpointers must start with \$", index);
    }
    return Stkptr(txt);
  }

  static Memptr verifiedMemorypointer(int index, String txt) {
    if (txt.length < 2) {
      throw ParserError("memptr missing", index);
    }
    int codeVal = txt.codeUnitAt(1);
    if (codeVal < 97 || codeVal > 122) {
      // a - z
      throw ParserError(
          "memory pointer names must start with lowercase latin letter", index);
    }
    if (txt[0] != "%") {
      throw ParserError("stackpointers must start with %", index);
    }
    return Memptr(txt);
  }

  static Number verifiedNumber(int index, String txt) {
    if (txt.isEmpty) {
      throw ParserError("argument missing", index);
    }
    int? resi = int.tryParse(txt);
    if (resi != null) {
      return Integer(resi);
    }

    double? resd = double.tryParse(txt);
    if (resd != null) {
      return Float(resd);
    }
    throw ParserError("expected a number argument", index);
  }

  static Float verifiedFloat(int index, String txt) {
    if (txt.isEmpty) {
      throw ParserError("argument missing", index);
    }
    double? res = double.tryParse(txt);
    if (res != null) {
      return Float(res);
    }

    throw ParserError("expected a integer argument", index);
  }

  static Integer verifiedInteger(int index, String txt) {
    if (txt.isEmpty) {
      throw ParserError("argument missing", index);
    }
    int? resi = int.tryParse(txt);
    if (resi != null) {
      return Integer(resi);
    }

    throw ParserError("expected a integer argument", index);
  }

  static StackInt verifiedStackOrInt(int index, String arg) {
    if (arg.startsWith("\$")) {
      return _ArgumentParser.verifiedStackpointer(index, arg);
    } else {
      return _ArgumentParser.verifiedInteger(index, arg);
    }
  }

  static StackIntFloat verifiedStackIntFloat(int index, String arg) {
    if (arg.startsWith("\$")) {
      return _ArgumentParser.verifiedStackpointer(index, arg);
    } else if (arg.contains(".")) {
      return _ArgumentParser.verifiedFloat(index, arg);
    } else {
      return _ArgumentParser.verifiedInteger(index, arg);
    }
  }
}

class ParserError extends Error {
  String message;
  int lineIndex;
  ParserError(this.message, this.lineIndex);

  @override
  String toString() {
    return "PARSER ERROR at line $lineIndex: $message";
  }
}
