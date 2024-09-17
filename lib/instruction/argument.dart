sealed class Argument {}

sealed class Memorizable {
  Integer isEqualTo(Memorizable other);
  String get txt;
}

sealed class Number implements Memorizable {}

sealed class StackInt {
  String get txt;
}

class Integer implements Argument, Number, Memorizable, StackInt {
  final int value;
  Integer(this.value);

  @override
  Integer isEqualTo(Memorizable other) {
    if (other is Integer && other.value == value) {
      return Integer(1);
    }
    return Integer(0);
  }

  @override
  String get txt => "$value";
}

class Float implements Argument, Number, Memorizable {
  final double value;
  Float(this.value);

  @override
  Integer isEqualTo(Memorizable other) {
    if (other is Float && other.value == value) {
      return Integer(1);
    }
    return Integer(0);
  }

  @override
  String get txt => "$value";
}

/*
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

  @override
  String get txt => value;
}
*/

class Stkptr implements Argument, Memorizable, StackInt {
  final String value;
  Stkptr(this.value);

  @override
  Integer isEqualTo(Memorizable other) {
    if (other is Stkptr && other.value == value) {
      return Integer(1);
    }
    return Integer(0);
  }

  static Stkptr? tryParse(String txt) {
    if (txt.startsWith('%') && !txt.contains(" ") && !txt.contains("\n")) {
      return Stkptr(txt);
    }
    return null;
  }

  @override
  String get txt => value;
}

class Label implements Argument {
  final String value;
  Label(this.value);

  String get txt => value;
}
