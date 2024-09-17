import 'package:mali/instruction/argument.dart';

sealed class Instruction {
  String get txt;
}

class ALLOCInstruction implements Instruction {
  // ALLOC %
  final Stkptr stkptr;
  ALLOCInstruction(this.stkptr);

  @override
  String get txt => "ALLOC ${stkptr.value}";
}

class FREEInstruction implements Instruction {
  // FREE %
  final Stkptr stkptr;
  FREEInstruction(this.stkptr);
  @override
  String get txt => "FREE ${stkptr.value}";
}
class LABELInstruction implements Instruction {
  // LABEL label
  final Label label;
  LABELInstruction(this.label);
  @override
  String get txt => "LABEl ${label.txt}";
}

class CALLInstruction implements Instruction {
  // CALL label
  final Label label;
  CALLInstruction(this.label);
  @override
  String get txt => "CALL ${label.txt}";
}

class GOTOInstruction implements Instruction {
  // GOTO label
  final Label label;
  GOTOInstruction(this.label);
  @override
  String get txt => "GOTO ${label.txt}";
}

class JMP0Instruction implements Instruction {
  // JMP0 $ label
  final Stkptr stkptr;
  final Label label;
  JMP0Instruction(this.stkptr, this.label);
  @override
  String get txt => "JMP0 ${stkptr.txt} ${label.txt}";
}

class JMP1Instruction implements Instruction {
  // JMP0 $ label
  final Stkptr stkptr;
  final Label label;
  JMP1Instruction(this.stkptr, this.label);
  @override
  String get txt => "JMP1 ${stkptr.txt} ${label.txt}";
}

class RETInstruction implements Instruction {
  @override
  String get txt => "RET";
}

class EXITInstruction implements Instruction {
  final StackInt argument;
  EXITInstruction(this.argument);
  @override
  String get txt => "EXIT ${argument.txt}";
}

class OUTInstruction implements Instruction {
  // OUT %
  final Stkptr stkptr;
  OUTInstruction(this.stkptr);
  @override
  String get txt => "OUT ${stkptr.value}";
}

class PUSHInstruction implements Instruction {
  // PUSH (i,f) $
  final Number value;
  final Stkptr stkptr;
  PUSHInstruction(this.value, this.stkptr);
  @override
  String get txt => "PUSH ${value.txt} ${stkptr.value}";
}

class CPYInstruction implements Instruction {
  // CPY $ $
  final Stkptr src;
  final Stkptr dest;
  CPYInstruction(this.src, this.dest);
  @override
  String get txt => "CPY ${src.value} ${dest.value}";
}

class MOVInstruction implements Instruction {
  // MOV $ $
  final Stkptr src;
  final Stkptr dest;
  MOVInstruction(this.src, this.dest);
  @override
  String get txt => "MOV ${src.value} ${dest.value}";
}

class POPInstruction implements Instruction {
  // POP $
  final Stkptr stkptr;
  POPInstruction(this.stkptr);
  @override
  String get txt => "POP ${stkptr.value}";
}

class EQInstruction implements Instruction {
  // EQ $
  final Stkptr stkptr;
  EQInstruction(this.stkptr);
  @override
  String get txt => "EQ ${stkptr.value}";
}

class EQVInstruction implements Instruction {
  // EQV $ (i,f)
  final Stkptr stkptr;
  final Number value;
  EQVInstruction(this.stkptr, this.value);
  @override
  String get txt => "EQV ${stkptr.value} ${value.txt}";
}

class ADDInstruction implements Instruction {
  // ADD $
  final Stkptr stkptr;
  ADDInstruction(this.stkptr);
  @override
  String get txt => "ADD ${stkptr.value}";
}

class SUBInstruction implements Instruction {
  // SUB $
  final Stkptr stkptr;
  SUBInstruction(this.stkptr);
  @override
  String get txt => "SUB ${stkptr.value}";
}

class MULInstruction implements Instruction {
  // MUL $
  final Stkptr stkptr;
  MULInstruction(this.stkptr);
  @override
  String get txt => "MUL ${stkptr.value}";
}

class DIVInstruction implements Instruction {
  // MUL $
  final Stkptr stkptr;
  DIVInstruction(this.stkptr);
  @override
  String get txt => "DIV ${stkptr.value}";
}

class MODInstruction implements Instruction {
  // MOD $
  final Stkptr stkptr;
  MODInstruction(this.stkptr);
  @override
  String get txt => "MOD ${stkptr.value}";
}

class ANDInstruction implements Instruction {
  // AND $
  final Stkptr stkptr;
  ANDInstruction(this.stkptr);
  @override
  String get txt => "AND ${stkptr.value}";
}

class ORInstruction implements Instruction {
  // OR $
  final Stkptr stkptr;
  ORInstruction(this.stkptr);
  @override
  String get txt => "OR ${stkptr.value}";
}
/*
class LOADInstruction implements Instruction {
  // LOAD % i $
  final Memptr memptr;
  final int pos;
  final Stkptr stkptr;
  LOADInstruction(this.memptr, this.pos, this.stkptr);

  @override
  String get txt => "LOAD ${memptr.txt} $pos ${stkptr.txt}";
}

class LOADHInstruction implements Instruction {
  // LOADH % $
  final Memptr memptr;
  final Stkptr stkptr;
  LOADHInstruction(this.memptr, this.stkptr);

  @override
  String get txt => "LOADH ${memptr.txt} ${stkptr.txt}";
}

class LOADLInstruction implements Instruction {
  // LOADL % $
  final Memptr memptr;
  final Stkptr stkptr;
  LOADLInstruction(this.memptr, this.stkptr);

  @override
  String get txt => "LOADL ${memptr.txt} ${stkptr.txt}";
}

class STOREInstruction implements Instruction {
  // STORE ($,i,f) %
  final StackIntFloat src;
  final Memptr dest;
  STOREInstruction(this.src, this.dest);

  @override
  String get txt => "STORE ${src.txt} ${dest.txt}";
}

class STOREHInstruction implements Instruction {
  // STOREH $ %
  final StackIntFloat src;
  final Memptr dest;
  STOREHInstruction(this.src, this.dest);

  @override
  String get txt => "STOREH ${src.txt} ${dest.txt}";
}

class REMLInstruction implements Instruction {
  // REML %
  final Memptr memptr;
  REMLInstruction(this.memptr);
  @override
  String get txt => "REML ${memptr.value}";
}

class REMHInstruction implements Instruction {
  // REMH %
  final Memptr memptr;
  REMHInstruction(this.memptr);
  @override
  String get txt => "REMH ${memptr.value}";
}

*/
/*
class LOADInstruction implements Instruction {
  // LOAD % i $
  final Memptr memptr;
  final int pos;
  final Stkptr stkptr;
  LOADInstruction(this.memptr, this.pos, this.stkptr);

  @override
  String get txt => "LOAD ${memptr.txt} $pos ${stkptr.txt}";
}

class LOADHInstruction implements Instruction {
  // LOADH % $
  final Memptr memptr;
  final Stkptr stkptr;
  LOADHInstruction(this.memptr, this.stkptr);

  @override
  String get txt => "LOADH ${memptr.txt} ${stkptr.txt}";
}

class LOADLInstruction implements Instruction {
  // LOADL % $
  final Memptr memptr;
  final Stkptr stkptr;
  LOADLInstruction(this.memptr, this.stkptr);

  @override
  String get txt => "LOADL ${memptr.txt} ${stkptr.txt}";
}

class STOREInstruction implements Instruction {
  // STORE ($,i,f) %
  final StackIntFloat src;
  final Memptr dest;
  STOREInstruction(this.src, this.dest);

  @override
  String get txt => "STORE ${src.txt} ${dest.txt}";
}

class STOREHInstruction implements Instruction {
  // STOREH $ %
  final StackIntFloat src;
  final Memptr dest;
  STOREHInstruction(this.src, this.dest);

  @override
  String get txt => "STOREH ${src.txt} ${dest.txt}";
}

class REMLInstruction implements Instruction {
  // REML %
  final Memptr memptr;
  REMLInstruction(this.memptr);
  @override
  String get txt => "REML ${memptr.value}";
}

class REMHInstruction implements Instruction {
  // REMH %
  final Memptr memptr;
  REMHInstruction(this.memptr);
  @override
  String get txt => "REMH ${memptr.value}";
}

*/
