import 'package:mali/run.dart';

int run() {
  String code = """
      ALLOC %fizzbuzz
      STORE 122 %fizzbuzz
      ALLOC %fizz
      STORE 102 %fizz
      ALLOC %buzz
      STORE 100 %buzz

      LABEL main
      PUSH 1 \$fb_args
      CALL fizzbuzz
      EXIT 0

      LABEL fizzbuzz
      PUSH 3 \$fb
      CPY \$fb_args \$fb
      MOD \$fb
      EQV \$fb 0

      CPY \$fb_args \$fb
      PUSH 5 \$fb
      MOD \$fb
      EQV \$fb 0

      AND \$fb
      JMP0 \$fb fizzonly
      POP \$fb
      OUT %fizzbuzz
      RET

      LABEL fizzonly
      PUSH 3 \$fb
      CPY \$fb_args \$fb
      MOD \$fb
      EQV \$fb 0
      JMP0 \$fb buzzonly
      POP \$fb
      RET

      LABEL buzzonly
      PUSH 5 \$fb
      CPY \$fb_args \$fb
      MOD \$fb
      EQV \$fb 0
      JMP0 \$fb else
      POP \$fb
      RET

      LABEL else
      CPY \$fb_args \$fb
      PUSH 48 \$fb 
      ADD \$fb
      ALLOC %out
      STORE \$fb %out
      OUT %out
      FREE %out
      RET

      """;
  return Runner.run(code);
}
