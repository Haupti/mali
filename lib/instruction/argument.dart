sealed class Argument {}

sealed class Memorizable {}

sealed class Number implements Memorizable {}

sealed class StackIntFloat {}

sealed class StackInt {}

class Integer
    implements Argument, Number, Memorizable, StackIntFloat, StackInt {
  final int value;
  Integer(this.value);
}

class Float implements Argument, Number, Memorizable, StackIntFloat {
  final double value;
  Float(this.value);
}

class Memptr implements Argument, Memorizable {
  final String value;
  Memptr(this.value);
}

class Stkptr implements Argument, StackIntFloat, StackInt {
  final String value;
  Stkptr(this.value);
}

class Label implements Argument {
  final String value;
  Label(this.value);
}
