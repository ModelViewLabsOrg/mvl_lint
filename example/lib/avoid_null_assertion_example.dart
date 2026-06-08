class AvoidNullAssertionExample {
  void greet(String? name) {
    // avoid_null_assertion
    print(name!);
  }
}
