import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_global_state.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidGlobalStateRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidGlobalStateRule();
    super.setUp();
  }

  void test_top_level_mutable_variable() async {
    await assertDiagnostics(
      r'''
var globalMutable = 0;
''',
      [lint(4, 17)],
    );
  }

  void test_static_mutable_field() async {
    await assertDiagnostics(
      r'''
class Test {
  static int globalMutable = 0;
}
''',
      [lint(26, 17)],
    );
  }

  void test_final_variable_is_allowed() async {
    await assertNoDiagnostics(r'''
final globalFinal = 1;
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidGlobalStateRuleTest);
  });
}
