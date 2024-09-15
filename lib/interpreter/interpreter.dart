import 'dart:convert';
import 'dart:io';

import 'package:mali/instruction/argument.dart';
import 'package:mali/instruction/instruction.dart';

class RuntimeError extends Error {
  String message;
  RuntimeError(this.message);
  @override
  String toString() {
    return "RUNTIME ERROR: $message";
  }
}

class Stack {
  final List<Memorizable> _mem;
  Stack(this._mem);
  void push(Memorizable value) {
    _mem.add(value);
  }

  Memorizable? pop() {
    if (_mem.isEmpty) {
      return null;
    }
    return _mem.last;
  }

  static Stack init() {
    return Stack([]);
  }

  Memorizable? peekHead() {
    if (_mem.isEmpty) {
      return null;
    }
    return _mem.last;
  }

  int depth() {
    return _mem.length;
  }

  List<Memorizable> debug() {
    return _mem;
  }
}

class InstructionPointerStack {
  final List<int> _iptrs;
  InstructionPointerStack(this._iptrs);
  void push(int value) {
    _iptrs.add(value);
  }

  int? pop(int index) {
    if (_iptrs.isEmpty) {
      return null;
    }
    return _iptrs.last;
  }

  static InstructionPointerStack init() {
    return InstructionPointerStack([]);
  }
}

class Interpreter {
  static int run(
      List<Instruction> instructions, Map<String, int> labelToInstr) {
    var (exitVal, _, _, _, _) = runDebug(instructions, labelToInstr);
    return exitVal;
  }

  static (
    int exitVal,
    Map<String, int> labelToInstr,
    Map<String, Stack> stacks,
    Map<String, List<Memorizable>> memory,
    InstructionPointerStack iptrs
  ) runDebug(List<Instruction> instructions, Map<String, int> labelToInstr) {
    final Map<String, Stack> stacks = {};
    final Map<String, List<Memorizable>> memory = {};
    final InstructionPointerStack iptrs = InstructionPointerStack.init();

    int i;
    Instruction instr;
    for (i = 0; i < instructions.length; i++) {
      instr = instructions[i];
      switch (instr) {
        case ORInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(OR, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runOr(i, head, hot));
        case ANDInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(AND, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runAnd(i, head, hot));
        case MODInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(MOD, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runMod(i, head, hot));
        case DIVInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(DIV, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runDiv(i, head, hot));
        case MULInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(MUL, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runMul(i, head, hot));
        case SUBInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(SUB, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runSub(i, head, hot));
        case ADDInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(ADD, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(runAdd(i, head, hot));
        case EQVInstruction _:
          if (stacks[instr.stkptr.value] == null) {
            throw RuntimeError(
                "(EQV, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable? head = stacks[instr.stkptr.value]!.pop();
          if (head == null) {
            throw RuntimeError(
                "(EQV, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          stacks[instr.stkptr.value]!.push(head.isEqualTo(instr.value));
        case EQInstruction _:
          if (stacks[instr.stkptr.value] == null ||
              stacks[instr.stkptr.value]!.depth() < 2) {
            throw RuntimeError(
                "(EQ, $i) not enough values on stack: ${instr.stkptr.value}");
          }
          Memorizable head = stacks[instr.stkptr.value]!.pop()!;
          Memorizable hot = stacks[instr.stkptr.value]!.pop()!;
          stacks[instr.stkptr.value]!.push(head.isEqualTo(hot));
        case POPInstruction _:
          if (stacks[instr.stkptr.value] == null) {
            throw RuntimeError(
                "(POP, $i) stack is empty: ${instr.stkptr.value}");
          }
          stacks[instr.stkptr.value]!.pop();
        case MOVInstruction _:
          if (stacks[instr.src.value] == null) {
            throw RuntimeError(
                "(MOV, $i) move soure is empty: ${instr.src.value}");
          }
          if (stacks[instr.dest.value] == null) {
            stacks[instr.dest.value] = Stack.init();
          }
          Memorizable? val = stacks[instr.src.value]!.pop();
          if (val == null) {
            throw RuntimeError(
                "(MOV, $i) move soure is empty: ${instr.src.value}");
          }
          stacks[instr.dest.value]!.push(val);
        case CPYInstruction _:
          if (stacks[instr.src.value] == null) {
            throw RuntimeError(
                "(CPY, $i) copy soure is empty: ${instr.src.value}");
          }
          if (stacks[instr.dest.value] == null) {
            stacks[instr.dest.value] = Stack.init();
          }
          Memorizable? val = stacks[instr.src.value]!.peekHead();
          if (val == null) {
            throw RuntimeError(
                "(CPY, $i) copy soure is empty: ${instr.src.value}");
          }
          stacks[instr.dest.value]!.push(val);
        case PUSHInstruction _:
          Stack? stk = stacks[instr.stkptr.value];
          if (stk == null) {
            stacks[instr.stkptr.value] = Stack.init();
            stacks[instr.stkptr.value]!.push(instr.value);
          } else {
            stacks[instr.stkptr.value]!.push(instr.value);
          }
        case OUTInstruction _:
          List<Memorizable>? mem = memory[instr.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(OUT, $i) memory is not allocated ${instr.memptr.value}");
          }
          List<int> ints = mem.map((it) {
            if (it is Integer) {
              return it.value;
            } else {
              throw RuntimeError(
                  "(OUT, $i) memory expected to be integers only");
            }
          }).toList();
          utf8.decode(ints);
        case JMP1Instruction _:
          int? res = labelToInstr[instr.label.value];
          if (res == null) {
            throw RuntimeError("(JMP1, $i) label not defined");
          }
          Stack? stack = stacks[instr.stkptr.value];
          if (stack == null || stack.peekHead() == null) {
            throw RuntimeError("(JMP1, $i) stack empty: ${instr.stkptr.value}");
          }
          Memorizable? val = stack.peekHead();
          if (val is Integer && val.value == 1) {
            i = res - 1;
          }
        case JMP0Instruction _:
          int? res = labelToInstr[instr.label.value];
          if (res == null) {
            throw RuntimeError("(JMP0, $i) label not defined");
          }
          Stack? stack = stacks[instr.stkptr.value];
          if (stack == null || stack.peekHead() == null) {
            throw RuntimeError("(JMP0, $i) stack empty: ${instr.stkptr.value}");
          }
          Memorizable? val = stack.peekHead();
          if (val is Integer && val.value == 0) {
            i = res - 1;
          }
        case RETInstruction _:
          int? res = iptrs.pop(i);
          if (res == null) {
            throw RuntimeError(
                "(RET, $i) no instruction in instruction pointer stack to return to");
          }
          // because in next iteration, i will be incremented and THEN be at the right position
          i = res + 1;
        case GOTOInstruction _:
          int? res = labelToInstr[instr.label.value];
          if (res == null) {
            throw RuntimeError(
                "(GOTO, $i) label not defined: ${instr.label.value}");
          }
          // because in next iteration, i will be incremented and THEN be at the right position
          i = res - 1;
        case CALLInstruction _:
          int? res = labelToInstr[instr.label.value];
          if (res == null) {
            throw RuntimeError(
                "(CALL, $i) label not defined ${instr.label.value}");
          }
          // because in next iteration, i will be incremented and THEN be at the right position
          i = res - 1;
          iptrs.push(i);
        case LABELInstruction _:
          continue;
        case REMLInstruction _:
          if (memory[instr.memptr.value] == null) {
            throw RuntimeError(
                "(REML, $i) memory at is not allocated ${instr.memptr.value}");
          }
          memory[instr.memptr.value]!.removeLast();
        case REMHInstruction _:
          if (memory[instr.memptr.value] == null) {
            throw RuntimeError(
                "(REMH, $i) memory at is not allocated ${instr.memptr.value}");
          }
          memory[instr.memptr.value]!.removeAt(0);
        case STOREHInstruction _:
          if (memory[instr.dest.value] == null) {
            throw RuntimeError(
                "(STOREH, $i) memory at is not allocated ${instr.dest.value}");
          }
          switch (instr.src) {
            case Integer val:
              memory[instr.dest.value]!.add(val);
            case Float val:
              memory[instr.dest.value]!.add(val);
            case Stkptr stk:
              if (stacks[stk.value] == null) {
                throw RuntimeError("(STORE, $i) stack is empty ${stk.value}");
              } else {
                Memorizable? value = stacks[stk.value]!.pop();
                if (value == null) {
                  throw RuntimeError("(STORE, $i) stack is empty ${stk.value}");
                }
                memory[instr.dest.value]!.insert(0, value);
              }
          }
        case STOREInstruction _:
          if (memory[instr.dest.value] == null) {
            throw RuntimeError(
                "(STORE, $i) memory at is not allocated ${instr.dest.value}");
          }
          switch (instr.src) {
            case Integer val:
              memory[instr.dest.value]!.add(val);
            case Float val:
              memory[instr.dest.value]!.add(val);
            case Stkptr stk:
              if (stacks[stk.value] == null) {
                throw RuntimeError("(STORE, $i) stack is empty ${stk.value}");
              } else {
                Memorizable? value = stacks[stk.value]!.pop();
                if (value == null) {
                  throw RuntimeError("(STORE, $i) stack is empty ${stk.value}");
                }
                memory[instr.dest.value]!.add(value);
              }
          }

        case EXITInstruction _:
          runExit(stacks, instr.argument, i);
        case ALLOCInstruction _:
          if (memory[instr.memptr.value] != null) {
            throw RuntimeError(
                "(ALLOC, $i) memory at is already allocated ${instr.memptr.value}");
          }
          memory[instr.memptr.value] = [];
        case FREEInstruction _:
          if (memory[instr.memptr.value] == null) {
            throw RuntimeError(
                "(FREE, $i) memory is not allocated ${instr.memptr.value}");
          }
          memory.remove(instr.memptr.value);
        case LOADInstruction _:
          List<Memorizable>? mem = memory[instr.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(LOAD, $i) memory is not allocated ${instr.memptr.value}");
          }
          if (stacks[instr.stkptr.value] == null) {
            stacks[instr.stkptr.value] = Stack.init();
          }
          if (instr.pos >= mem.length) {
            throw RuntimeError("(LOAD, $i) no element at ${instr.pos}");
          }
          stacks[instr.stkptr.value]!.push(mem[instr.pos]);
        case LOADHInstruction _:
          List<Memorizable>? mem = memory[instr.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(LOADH, $i) memory is not allocated ${instr.memptr.value}");
          }
          if (stacks[instr.stkptr.value] == null) {
            stacks[instr.stkptr.value] = Stack.init();
          }
          if (mem.isEmpty) {
            throw RuntimeError("(LOADH, $i) no data at ${instr.stkptr.value}");
          }
          stacks[instr.stkptr.value]!.push(mem.first);
        case LOADLInstruction _:
          List<Memorizable>? mem = memory[instr.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(LOADH, $i) memory is not allocated ${instr.memptr.value}");
          }
          if (stacks[instr.stkptr.value] == null) {
            stacks[instr.stkptr.value] = Stack.init();
          }
          if (mem.isEmpty) {
            throw RuntimeError("(LOADL, $i) no data at ${instr.stkptr.value}");
          }
          stacks[instr.stkptr.value]!.push(mem.last);
      }
    }
    return 1;
  }

  static Memorizable runOr(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            if (fst.value == 1 || snd.value == 1) {
              return Integer(1);
            }
            return Integer(0);
          default:
            throw RuntimeError("(OR, $index) expected integer values");
        }

      default:
        throw RuntimeError("(OR, $index) expected integer values");
    }
  }

  static Memorizable runAnd(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            if (fst.value == 1 && snd.value == 1) {
              return Integer(1);
            }
            return Integer(0);
          default:
            throw RuntimeError("(AND, $index) expected integer values");
        }

      default:
        throw RuntimeError("(AND, $index) expected integer values");
    }
  }

  static Memorizable runMod(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            return Integer(fst.value % snd.value);
          default:
            throw RuntimeError(
                "(MOD, $index) cannot calculate mod on non-integer values");
        }

      default:
        throw RuntimeError(
            "(MOD, $index) cannot calculate mod on non-integer values");
    }
  }

  static Memorizable runDiv(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            return Float(fst.value / snd.value);
          case Float _:
            return Float(fst.value / snd.value);
          default:
            throw RuntimeError(
                "(DIV, $index) non-number values cannot be divided");
        }
      case Float _:
        switch (snd) {
          case Integer _:
            return Float(fst.value / snd.value);
          case Float _:
            return Float(fst.value / snd.value);
          default:
            throw RuntimeError(
                "(DIV, $index) non-number values cannot be divided");
        }
      default:
        throw RuntimeError("(DIV, $index) non-number values cannot be divided");
    }
  }

  static Memorizable runMul(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            return Integer(fst.value * snd.value);
          case Float _:
            return Float(fst.value * snd.value);
          default:
            throw RuntimeError(
                "(MUL, $index) non-number values cannot be multiplied");
        }
      case Float _:
        switch (snd) {
          case Integer _:
            return Float(fst.value * snd.value);
          case Float _:
            return Float(fst.value * snd.value);
          default:
            throw RuntimeError(
                "(MUL, $index) non-number values cannot be multiplied");
        }
      default:
        throw RuntimeError(
            "(MUL, $index) non-number values cannot be multiplied");
    }
  }

  static Memorizable runSub(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            return Integer(fst.value - snd.value);
          case Float _:
            return Float(fst.value - snd.value);
          default:
            throw RuntimeError(
                "(SUB, $index) non-number values cannot be subracted");
        }
      case Float _:
        switch (snd) {
          case Integer _:
            return Float(fst.value - snd.value);
          case Float _:
            return Float(fst.value - snd.value);
          default:
            throw RuntimeError(
                "(SUB, $index) non-number values cannot be subracted");
        }
      default:
        throw RuntimeError(
            "(SUB, $index) non-number values cannot be subracted");
    }
  }

  static Memorizable runAdd(int index, Memorizable fst, Memorizable snd) {
    switch (fst) {
      case Integer _:
        switch (snd) {
          case Integer _:
            return Integer(fst.value + snd.value);
          case Float _:
            return Float(fst.value + snd.value);
          default:
            throw RuntimeError(
                "(ADD, $index) non-number values cannot be added");
        }
      case Float _:
        switch (snd) {
          case Integer _:
            return Float(fst.value + snd.value);
          case Float _:
            return Float(fst.value + snd.value);
          default:
            throw RuntimeError(
                "(ADD, $index) non-number values cannot be added");
        }
      default:
        throw RuntimeError("(ADD, $index) non-number values cannot be added");
    }
  }

  static void runExit(Map<String, Stack> stacks, StackInt arg, int index) {
    switch (arg) {
      case Stkptr _:
        Stack? stack = stacks[arg.value];
        if (stack == null) {
          throw RuntimeError("(EXIT, $index) no stack: ${arg.value}");
        }
        Memorizable? val = stack.pop();
        if (val is Integer) {
          exit(val.value);
        } else {
          throw RuntimeError(
              "(EXIT, $index) expected an integer at head of stack: $val");
        }
      case Integer _:
        exit(arg.value);
    }
  }
}
