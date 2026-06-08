import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/prefer_early_return.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class PreferEarlyReturnRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferEarlyReturnRule();
    super.setUp();
  }

  void test_nested_if_without_return() async {
    await assertDiagnostics(
      r'''
void _doSomething() {}

void f() {
  if (true) {
    _doSomething();
  }
}
''',
      [lint(37, 35)],
    );
  }

  void test_if_with_else_is_allowed() async {
    await assertNoDiagnostics(r'''
void _doSomething() {}

void f(bool condition) {
  if (condition) {
    _doSomething();
  } else {
    _doSomething();
  }
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEarlyReturnRuleTest);
  });
}
