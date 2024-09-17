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
    int pos = _iptrs.last;
    _iptrs.removeLast();
    return pos;
  }

  static InstructionPointerStack init() {
    return InstructionPointerStack([]);
  }

  int get length {
    return _iptrs.length;
  }
}

