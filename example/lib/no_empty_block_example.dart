class NoEmptyBlockExample {
  // no_empty_block
  void empty() {}

  void emptyCatch() {
    try {
      print('move map');
    } catch (_) {}
  }
}
