import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/prefer_first.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class PreferFirstRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferFirstRule();
    super.setUp();
  }

  void test_index_zero_access() async {
    await assertDiagnostics(
      r'''
void f() {
  final list = [0, 1, 2, 3];
  list[0];
}
''',
      [lint(42, 7)],
    );
  }

  void test_first_access_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  final list = [0, 1, 2, 3];
  list.first;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferFirstRuleTest);
  });
}
