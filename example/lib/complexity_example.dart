class ComplexityExample {
  // cyclomatic_complexity
  // function_lines_of_code
  void complexAndLong(
    bool a,
    bool b,
    bool c,
    bool d,
    bool e,
    bool f,
    bool g,
  ) {
    if (a) {
      if (b) {
        if (c) {
          if (d) {
            if (e) {
              if (f) {
                if (g) {
                  print('nested');
                }
              }
            }
          }
        }
      }
    }
    print('line 1');
    print('line 2');
    print('line 3');
    print('line 4');
  }
}
