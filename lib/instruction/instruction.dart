import 'package:mali/instruction/argument.dart';

sealed class Instruction {}

class ALLOCInstruction implements Instruction {
  // ALLOC %
  final Memptr memptr;
  ALLOCInstruction(this.memptr);
}

class FREEInstruction implements Instruction {
  // FREE %
  final Memptr memptr;
  FREEInstruction(this.memptr);
}

class LOADInstruction implements Instruction {
  // LOAD % i $
  final Memptr memptr;
  final int pos;
  final Stkptr stkptr;
  LOADInstruction(this.memptr, this.pos, this.stkptr);
}

class LOADHInstruction implements Instruction {
  // LOADH % $
  final Memptr memptr;
  final Stkptr stkptr;
  LOADHInstruction(this.memptr, this.stkptr);
}

class LOADLInstruction implements Instruction {
  // LOADL % $
  final Memptr memptr;
  final Stkptr stkptr;
  LOADLInstruction(this.memptr, this.stkptr);
}

class STOREInstruction implements Instruction {
  // STORE ($,i,f) %
  final StackIntFloat src;
  final Memptr dest;
  STOREInstruction(this.src, this.dest);
}

class STOREHInstruction implements Instruction {
  // STOREH $ %
  final Stkptr stkptr;
  final Memptr memptr;
  STOREHInstruction(this.stkptr, this.memptr);
}

class REMLInstruction implements Instruction {
  // REML %
  final Memptr memptr;
  REMLInstruction(this.memptr);
}

class REMHInstruction implements Instruction {
  // REMH %
  final Memptr memptr;
  REMHInstruction(this.memptr);
}

class LABELInstruction implements Instruction {
  // LABEL label
  final Label label;
  LABELInstruction(this.label);
}

class CALLInstruction implements Instruction {
  // CALL label
  final Label label;
  CALLInstruction(this.label);
}

class GOTOInstruction implements Instruction {
  // GOTO label
  final Label label;
  GOTOInstruction(this.label);
}

class JMP0Instruction implements Instruction {
  // JMP0 $ label
  final Stkptr stkptr;
  final Label label;
  JMP0Instruction(this.stkptr, this.label);
}

class JMP1Instruction implements Instruction {
  // JMP0 $ label
  final Stkptr stkptr;
  final Label label;
  JMP1Instruction(this.stkptr, this.label);
}

class RETInstruction implements Instruction {}

class EXITInstruction implements Instruction {
  final StackInt argument;
  EXITInstruction(this.argument);
}

class OUTInstruction implements Instruction {
  // OUT %
  final Memptr memptr;
  OUTInstruction(this.memptr);
}

class PUSHInstruction implements Instruction {
  // PUSH (i,f) $
  final Number value;
  final Stkptr stkptr;
  PUSHInstruction(this.value, this.stkptr);
}

class CPYInstruction implements Instruction {
  // CPY $ $
  final Stkptr src;
  final Stkptr dest;
  CPYInstruction(this.src, this.dest);
}

class MOVInstruction implements Instruction {
  // MOV $ $
  final Stkptr src;
  final Stkptr dest;
  MOVInstruction(this.src, this.dest);
}

class POPInstruction implements Instruction {
  // POP $
  final Stkptr stkptr;
  POPInstruction(this.stkptr);
}

class EQInstruction implements Instruction {
  // EQ $
  final Stkptr stkptr;
  EQInstruction(this.stkptr);
}

class EQVInstruction implements Instruction {
  // EQV $ (i,f)
  final Stkptr stkptr;
  final Number value;
  EQVInstruction(this.stkptr, this.value);
}

class ADDInstruction implements Instruction {
  // ADD $
  final Stkptr stkptr;
  ADDInstruction(this.stkptr);
}

class SUBInstruction implements Instruction {
  // SUB $
  final Stkptr stkptr;
  SUBInstruction(this.stkptr);
}

class MULInstruction implements Instruction {
  // MUL $
  final Stkptr stkptr;
  MULInstruction(this.stkptr);
}

class DIVInstruction implements Instruction {
  // MUL $
  final Stkptr stkptr;
  DIVInstruction(this.stkptr);
}

class MODInstruction implements Instruction {
  // MOD $
  final Stkptr stkptr;
  MODInstruction(this.stkptr);
}

class ANDInstruction implements Instruction {
  // AND $
  final Stkptr stkptr;
  ANDInstruction(this.stkptr);
}

class ORInstruction implements Instruction {
  // OR $
  final Stkptr stkptr;
  ORInstruction(this.stkptr);
}
