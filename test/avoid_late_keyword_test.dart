import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_late_keyword.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidLateKeywordRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidLateKeywordRule();
    super.setUp();
  }

  void test_late_field() async {
    await assertDiagnostics(
      r'''
class Test {
  late int value;
}
''',
      [lint(24, 5)],
    );
  }

  void test_late_local_variable() async {
    await assertDiagnostics(
      r'''
void f() {
  late int value;
}
''',
      [lint(22, 5)],
    );
  }

  void test_initialized_variable_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  int value = 0;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidLateKeywordRuleTest);
  });
}
