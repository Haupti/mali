sealed class Argument {}

sealed class Memorizable {
  Integer isEqualTo(Memorizable other);
}

sealed class Number implements Memorizable {}

sealed class StackIntFloat {}

sealed class StackInt {}

class Integer
    implements Argument, Number, Memorizable, StackIntFloat, StackInt {
  final int value;
  Integer(this.value);

  @override
  Integer isEqualTo(Memorizable other) {
    if (other is Integer && other.value == value) {
      return Integer(1);
    }
    return Integer(0);
  }
}

class Float implements Argument, Number, Memorizable, StackIntFloat {
  final double value;
  Float(this.value);

  @override
  Integer isEqualTo(Memorizable other) {
    if (other is Float && other.value == value) {
      return Integer(1);
    }
    return Integer(0);
  }
}

class Memptr implements Argument, Memorizable {
  final String value;
  Memptr(this.value);

  @override
  Integer isEqualTo(Memorizable other) {
    if (other is Memptr && other.value == value) {
      return Integer(1);
    }
    return Integer(0);
  }
}

class Stkptr implements Argument, StackIntFloat, StackInt {
  final String value;
  Stkptr(this.value);
}

class Label implements Argument {
  final String value;
  Label(this.value);
}
