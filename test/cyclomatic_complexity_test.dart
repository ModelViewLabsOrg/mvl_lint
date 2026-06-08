import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/cyclomatic_complexity.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class CyclomaticComplexityRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = CyclomaticComplexityRule(maxComplexity: 3);
    super.setUp();
  }

  void test_high_complexity() async {
    await assertDiagnostics(
      r'''
void f() {
  if (true) {
    if (true) {
      if (true) {}
    }
  }
}
''',
      [lint(9, 62)],
    );
  }

  void test_low_complexity_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  if (true) {}
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CyclomaticComplexityRuleTest);
  });
}
