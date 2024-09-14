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
}

class Interpreter {
  static int run(
      List<Instruction> instructions, Map<String, int> labelToInstr) {
    final Map<String, Stack> stacks = {};
    final Map<String, List<Memorizable>> memory = {};

    for (final (i, instruction) in instructions.indexed) {
      switch (instruction) {
        case EXITInstruction _:
          runExit(stacks, instruction.argument, i);
        case ALLOCInstruction _:
          if (memory[instruction.memptr.value] != null) {
            throw RuntimeError(
                "(ALLOC, $i) memory at is already allocated ${instruction.memptr.value}");
          }
          memory[instruction.memptr.value] = [];
        case FREEInstruction _:
          if (memory[instruction.memptr.value] == null) {
            throw RuntimeError(
                "(FREE, $i) memory is not allocated ${instruction.memptr.value}");
          }
          memory.remove(instruction.memptr.value);
        case LOADInstruction _:
          var mem = memory[instruction.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(LOAD, $i) memory is not allocated ${instruction.memptr.value}");
          }
          if (stacks[instruction.stkptr.value] == null) {
            stacks[instruction.stkptr.value] = Stack.init();
          }
          if (instruction.pos >= mem.length) {
            throw RuntimeError("(LOAD, $i) no element at ${instruction.pos}");
          }
          stacks[instruction.stkptr.value]!.push(mem[instruction.pos]);
        case LOADHInstruction _:
          var mem = memory[instruction.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(LOADH, $i) memory is not allocated ${instruction.memptr.value}");
          }
          if (stacks[instruction.stkptr.value] == null) {
            stacks[instruction.stkptr.value] = Stack.init();
          }
          if (mem.isEmpty) {
            throw RuntimeError(
                "(LOADH, $i) no data at ${instruction.stkptr.value}");
          }
          stacks[instruction.stkptr.value]!.push(mem.first);
        case LOADLInstruction _:
          var mem = memory[instruction.memptr.value];
          if (mem == null) {
            throw RuntimeError(
                "(LOADH, $i) memory is not allocated ${instruction.memptr.value}");
          }
          if (stacks[instruction.stkptr.value] == null) {
            stacks[instruction.stkptr.value] = Stack.init();
          }
          if (mem.isEmpty) {
            throw RuntimeError(
                "(LOADL, $i) no data at ${instruction.stkptr.value}");
          }
          stacks[instruction.stkptr.value]!.push(mem.last);
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
