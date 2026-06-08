import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/prefer_last.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class PreferLastRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferLastRule();
    super.setUp();
  }

  void test_last_element_by_index() async {
    await assertDiagnostics(
      r'''
void f() {
  final list = [0, 1, 2, 3];
  list[list.length - 1];
}
''',
      [lint(42, 21)],
    );
  }

  void test_last_access_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  final list = [0, 1, 2, 3];
  list.last;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferLastRuleTest);
  });
}
