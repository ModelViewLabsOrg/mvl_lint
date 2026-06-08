import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/prefer_match_file_name.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class PreferMatchFileNameRuleTest extends AnalysisRuleTest {
  @override
  String get testFileName => 'my_class.dart';

  @override
  void setUp() {
    rule = PreferMatchFileNameRule();
    super.setUp();
  }

  void test_mismatched_file_name() async {
    await assertDiagnostics(
      r'''
class WrongClass {}
''',
      [lint(6, 10)],
    );
  }

  void test_matching_file_name() async {
    await assertNoDiagnostics(r'''
class MyClass {}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferMatchFileNameRuleTest);
  });
}
