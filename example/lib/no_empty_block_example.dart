class NoEmptyBlockExample {
  // no_empty_block
  void empty() {}

  void emptyCatch1() {
    try {} catch (_) {}
  }

  void emptyCatch2() {
    try {} catch (e) {}
  }
}
