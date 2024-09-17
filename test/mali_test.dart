import 'package:mali/instruction/argument.dart';
import 'package:mali/run.dart';
import 'package:test/test.dart';

void main() {
  test('fizzbuzz test 1', () {
    var (exitVal, labelToInstr, stacks, iptrs) = Runner.runDebug("""
      PUSH 3 %fb
      PUSH 1 %fb
      MOD %fb
      EQV %fb 0

      PUSH 5 %fb
      PUSH 1 %fb
      MOD %fb
      EQV %fb 0

      AND %fb
      JMP0 %fb skip

      PUSH 99 %fb
      LABEL skip
      """);
    expect(labelToInstr.keys.length, 1);
    expect(stacks.keys.length, 1);
    expect((stacks["%fb"]!.peekHead() as Integer).value, 0);
    expect(stacks["%fb"]!.depth(), 1);
    expect(iptrs.length, 0);
  });
  test('ret works', () {
    var (exitVal, labelToInstr, stacks, iptrs) = Runner.runDebug("""
      CALL func
      CALL skip

      LABEL func
      PUSH 1 %a
      RET

      LABEL skip
      """);
    expect(labelToInstr.keys.length, 2);
    expect(stacks.keys.length, 1);
    expect((stacks["%a"]!.peekHead() as Integer).value, 1);
    expect(stacks["%a"]!.depth(), 1);
    expect(iptrs.length, 1);
  });
  test('jmp0 jumps', () {
    var (exitVal, labelToInstr, stacks, iptrs) = Runner.runDebug("""
      PUSH 0 %a
      JMP0 %a skip
      PUSH 42 %a
      LABEL skip
      """);
    expect(labelToInstr.keys.length, 1);
    expect(stacks.keys.length, 1);
    expect((stacks["%a"]!.peekHead() as Integer).value, 0);
    expect(stacks["%a"]!.depth(), 1);
    expect(iptrs.length, 0);
  });
  test('jmp0 doesnt jump', () {
    var (exitVal, labelToInstr, stacks, iptrs) = Runner.runDebug("""
      PUSH 1 %a
      JMP0 %a skip
      PUSH 42 %a
      LABEL skip
      """);
    expect(labelToInstr.keys.length, 1);
    expect(stacks.keys.length, 1);
    expect((stacks["%a"]!.peekHead() as Integer).value, 42);
    expect(stacks["%a"]!.depth(), 2);
    expect(iptrs.length, 0);
  });
  test('jmp1 jumps', () {
    var (exitVal, labelToInstr, stacks, iptrs) = Runner.runDebug("""
      PUSH 1 %a
      JMP1 %a skip
      PUSH 42 %a
      LABEL skip
      """);
    expect(labelToInstr.keys.length, 1);
    expect(stacks.keys.length, 1);
    expect((stacks["%a"]!.peekHead() as Integer).value, 1);
    expect(stacks["%a"]!.depth(), 1);
    expect(iptrs.length, 0);
  });
  test('jmp1 doesnt jump', () {
    var (exitVal, labelToInstr, stacks, iptrs) = Runner.runDebug("""
      PUSH 0 %a
      JMP1 %a skip
      PUSH 42 %a
      LABEL skip
      """);
    expect(exitVal, 1);
    expect(labelToInstr.keys.length, 1);
    expect(stacks.keys.length, 1);
    expect((stacks["%a"]!.peekHead() as Integer).value, 42);
    expect(stacks["%a"]!.depth(), 2);
    expect(iptrs.length, 0);
  });
}
