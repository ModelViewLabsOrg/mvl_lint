import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/number_of_parameters.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class NumberOfParametersRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NumberOfParametersRule(maxParameters: 2);
    super.setUp();
  }

  void test_too_many_parameters() async {
    await assertDiagnostics(
      r'''
String f(String a, String b, String c) {
  return a + b + c;
}
''',
      [lint(0, 62)],
    );
  }

  void test_acceptable_parameter_count() async {
    await assertNoDiagnostics(r'''
String f(String a, String b) {
  return a + b;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NumberOfParametersRuleTest);
  });
}
