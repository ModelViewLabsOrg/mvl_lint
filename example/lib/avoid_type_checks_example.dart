class AvoidTypeChecksExample {
  void run() {
    final numbers = [1.0, 2.0, 3.0];
    final strings = [1, 2, 3];

    // avoid_unnecessary_type_assertions
    final isDoubleList = numbers is List<double>;

    // avoid_unnecessary_type_casts
    final casted = numbers as List<double>;

    // avoid_unrelated_type_assertions
    final unrelated = strings is List<String>;
    print(isDoubleList);
    print(casted);
    print(unrelated);
  }
}
