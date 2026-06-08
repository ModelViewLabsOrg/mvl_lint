class AvoidNullAssertionExample {
  void greet(String? name) {
    // avoid_null_assertion
    print(name!);
  }

  void validate(String? value) {
    // avoid_null_assertion
    final message = value!.isEmpty ? 'required' : null;
    print(message);
  }
}
