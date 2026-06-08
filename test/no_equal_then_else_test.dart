import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/no_equal_then_else.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class NoEqualThenElseRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoEqualThenElseRule();
    super.setUp();
  }

  void test_equal_if_branches() async {
    await assertDiagnostics(
      r'''
void f() {
  final value = 1;
  int result = 0;
  if (value == 1) {
    result = value;
  } else {
    result = value;
  }
}
''',
      [lint(50, 72)],
    );
  }

  void test_different_branches_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  final valueA = 1;
  final valueB = 2;
  int result = 0;
  if (valueA == 1) {
    result = valueA;
  } else {
    result = valueB;
  }
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoEqualThenElseRuleTest);
  });
}
