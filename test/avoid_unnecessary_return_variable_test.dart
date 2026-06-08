import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_unnecessary_return_variable.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidUnnecessaryReturnVariableRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryReturnVariableRule();
    super.setUp();
  }

  void test_unnecessary_return_variable() async {
    await assertDiagnostics(
      r'''
int f() {
  final result = 1;
  return result;
}
''',
      [lint(32, 14)],
    );
  }

  void test_direct_return_is_allowed() async {
    await assertNoDiagnostics(r'''
int f() {
  return 1;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryReturnVariableRuleTest);
  });
}
