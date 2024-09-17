import 'package:mali/run.dart';

int run() {
  String code = """
      ALLOC %fizzbuzz
      PUSH 122 %fizzbuzz
      ALLOC %fizz
      PUSH 102 %fizz
      ALLOC %buzz
      PUSH 100 %buzz

      LABEL main
        PUSH 17 %fb_args
        CALL fizzbuzz
        EXIT 0

      LABEL fizzbuzz
        PUSH 3 %fb
        CPY %fb_args %fb
        MOD %fb
        EQV %fb 0

        PUSH 5 %fb
        CPY %fb_args %fb
        MOD %fb
        EQV %fb 0

        AND %fb
        JMP0 %fb fizzonly
        POP %fb
        OUT %fizzbuzz
        RET

        LABEL fizzonly
        PUSH 3 %fb
        CPY %fb_args %fb
        MOD %fb
        EQV %fb 0
        JMP0 %fb buzzonly
        OUT %fizz
        POP %fb
        RET

        LABEL buzzonly
        PUSH 5 %fb
        CPY %fb_args %fb
        MOD %fb
        EQV %fb 0
        JMP0 %fb else
        OUT %buzz
        POP %fb
        RET

        LABEL else
        CPY %fb_args %fb
        PUSH 48 %fb 
        ADD %fb
        OUT %fb
        FREE %fb
        RET

      """;
  return Runner.run(code);
}
