import 'package:mali/instruction/argument.dart';
import 'package:mali/instruction/instruction.dart';

typedef ParserResult = (
  List<Instruction> instructions,
  Map<String, int> labelInstrPointers
);

class Parser {
  static ParserResult parse(String code) {
    List<(int, String)> linesAndContents = _cleanLines(code);
    Map<String, int> labelInstrPointers = {};

    List<Instruction> instructions = [];
    List<String> parts;
    for (final (linenr, line) in linesAndContents) {
      parts = line.split(" ");
      switch (parts) {
        case ['REMH', String arg]:
          instructions.add(REMHInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, arg)));
        case ['REML', String arg]:
          instructions.add(REMLInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, arg)));
        case ['STOREH', String fst, String snd]:
          instructions.add(STOREHInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, fst),
              _ArgumentParser.verifiedMemorypointer(linenr, snd)));
        case ['STORE', String fst, String snd]:
          instructions.add(STOREInstruction(
              _ArgumentParser.verifiedStackIntFloat(linenr, fst),
              _ArgumentParser.verifiedMemorypointer(linenr, snd)));
        case ['LOADL', String memptr, String stkptr]:
          instructions.add(LOADLInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr),
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['LOADH', String memptr, String stkptr]:
          instructions.add(LOADHInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr),
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['LOAD', String memptr, String pos, String stkptr]:
          instructions.add(LOADInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr),
              _ArgumentParser.verifiedInteger(linenr, pos).value,
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['JMP0', String stkptr, String label]:
          instructions.add(JMP0Instruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr),
              _ArgumentParser.verifiedLabel(
                  linenr, labelInstrPointers, label)));
        case ['JMP1', String stkptr, String label]:
          instructions.add(JMP1Instruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr),
              _ArgumentParser.verifiedLabel(
                  linenr, labelInstrPointers, label)));
        case ['EXIT', String arg]:
          instructions.add(
              EXITInstruction(_ArgumentParser.verifiedStackOrInt(linenr, arg)));
        case ['LABEL', String labelraw]:
          Label label = _ArgumentParser.verifiedNewLabel(
              linenr, labelInstrPointers, labelraw);
          labelInstrPointers[label.value] = linenr;
          instructions.add(LABELInstruction(label));
        case ['GOTO', String labelraw]:
          instructions.add(GOTOInstruction(_ArgumentParser.verifiedLabel(
              linenr, labelInstrPointers, labelraw)));
        case ['CALL', String label]:
          instructions.add(CALLInstruction(_ArgumentParser.verifiedLabel(
              linenr, labelInstrPointers, label)));
        case ['ADD', String stkptr]:
          instructions.add(ADDInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['SUB', String stkptr]:
          instructions.add(SUBInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['MUL', String stkptr]:
          instructions.add(MULInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['DIV', String stkptr]:
          instructions.add(DIVInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['MOD', String stkptr]:
          instructions.add(MODInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['AND', String stkptr]:
          instructions.add(ANDInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['OR', String stkptr]:
          instructions.add(ORInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['POP', String stkptr]:
          instructions.add(POPInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['EQ', String stkptr]:
          instructions.add(EQInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        case ['OUT', String memptr]:
          instructions.add(OUTInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr)));
        case ['ALLOC', String memptr]:
          instructions.add(ALLOCInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr)));
        case ['FREE', String memptr]:
          instructions.add(FREEInstruction(
              _ArgumentParser.verifiedMemorypointer(linenr, memptr)));
        case ['RET']:
          instructions.add(RETInstruction());
        case ['EQV', String stkptr, String value]:
          instructions.add(EQVInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, stkptr),
              _ArgumentParser.verifiedNumber(linenr, value)));
        case ['MOV', String src, String dest]:
          instructions.add(MOVInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, src),
              _ArgumentParser.verifiedStackpointer(linenr, dest)));
        case ['CPY', String src, String dest]:
          instructions.add(CPYInstruction(
              _ArgumentParser.verifiedStackpointer(linenr, src),
              _ArgumentParser.verifiedStackpointer(linenr, dest)));
        case ['PUSH', String value, String stkptr]:
          instructions.add(PUSHInstruction(
              _ArgumentParser.verifiedNumber(linenr, value),
              _ArgumentParser.verifiedStackpointer(linenr, stkptr)));
        default:
          throw ParserError("invalid instruction or usage: $line", linenr);
      }
    }
    return (instructions, labelInstrPointers);
  }

  static List<(int, String)> _cleanLines(String code) {
    List<String> linesWithComments =
        code.split("\n").map((it) => it.trim()).toList();

    List<(int, String)> lineAndContent = [];

    String line;
    for (int i = 0; i < linesWithComments.length; i++) {
      line = linesWithComments[i];
      if (!line.startsWith(";")) {
        int commentStart = line.indexOf(";");
        if (commentStart == -1) {
          lineAndContent.add((i, line));
        } else {
          lineAndContent.add((i, line.substring(0, commentStart)));
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
