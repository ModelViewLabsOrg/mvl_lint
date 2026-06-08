import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/function_lines_of_code.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class FunctionLinesOfCodeRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FunctionLinesOfCodeRule(maxLines: 2);
    super.setUp();
  }

  void test_long_function() async {
    await assertDiagnostics(
      r'''
int f() {
  var i = 0;
  i++;
  return i;
}
''',
      [lint(0, 43)],
    );
  }

  void test_short_function_is_allowed() async {
    await assertNoDiagnostics(r'''
int f() {
  return 1;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FunctionLinesOfCodeRuleTest);
  });
}
