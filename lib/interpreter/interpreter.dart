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

  Memorizable pop() {
    if (_mem.isEmpty) {}
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
  static int run(List<Instruction> instructions, Map<String, int> labelToInstr,
      dynamic uft8) {
    final Map<String, Stack> stacks = {};
    final Map<String, List<Memorizable>> memory = {};
    final InstructionPointerStack iptrs = InstructionPointerStack.init();

    int i;
    Instruction instr;
    for (i = 0; i < instructions.length; i++) {
      instr = instructions[i];
      switch (instr) {
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
          var stack = stacks[instr.stkptr.value];
          if (stack == null || stack.peekHead() == null) {
            throw RuntimeError("(JMP1, $i) stack empty: ${instr.stkptr.value}");
          }
          var val = stack.peekHead();
          if (val is Integer && val.value == 1) {
            i = res - 1;
          }
        case JMP0Instruction _:
          int? res = labelToInstr[instr.label.value];
          if (res == null) {
            throw RuntimeError("(JMP0, $i) label not defined");
          }
          var stack = stacks[instr.stkptr.value];
          if (stack == null || stack.peekHead() == null) {
            throw RuntimeError("(JMP0, $i) stack empty: ${instr.stkptr.value}");
          }
          var val = stack.peekHead();
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
          i = res;
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
                memory[instr.dest.value]!.insert(0, stacks[stk.value]!.pop());
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
                memory[instr.dest.value]!.add(stacks[stk.value]!.pop());
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
          var mem = memory[instr.memptr.value];
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
          var mem = memory[instr.memptr.value];
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
          var mem = memory[instr.memptr.value];
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
  }

  static void runExit(Map<String, Stack> stacks, StackInt arg, int index) {
    switch (arg) {
      case Stkptr _:
        var stack = stacks[arg.value];
        if (stack == null) {
          throw RuntimeError("(EXIT, $index) no stack: ${arg.value}");
        }
        var val = stack.pop();
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
