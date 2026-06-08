import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_unused_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidUnusedParametersRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnusedParametersRule();
    super.setUp();
  }

  void test_unused_parameter() async {
    await assertDiagnostics(
      r'''
void f(String s) {
  return;
}
''',
      [lint(7, 8)],
    );
  }

  void test_used_parameter_is_allowed() async {
    await assertNoDiagnostics(r'''
void f(String s) {
  print(s);
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnusedParametersRuleTest);
  });
}
