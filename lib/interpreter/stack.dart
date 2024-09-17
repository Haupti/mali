import 'package:mali/instruction/argument.dart';

class Stack {
  final List<Memorizable> _mem;
  List<Memorizable> get values => _mem.reversed.toList();
  Stack(this._mem);
  void push(Memorizable value) {
    _mem.add(value);
  }

  Memorizable? pop() {
    if (_mem.isEmpty) {
      return null;
    }

    Memorizable val = _mem.last;
    _mem.removeLast();
    return val;
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
