import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_unnecessary_type_casts.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidUnnecessaryTypeCastsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryTypeCastsRule();
    super.setUp();
  }

  void test_unnecessary_as_cast() async {
    await assertDiagnostics(
      r'''
void f() {
  final testList = [1.0, 2.0, 3.0];
  final result = testList as List<double>;
}
''',
      [
        error(diag.unnecessaryCast, 64, 24),
        lint(64, 24),
      ],
    );
  }

  void test_nullable_cast_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  final double? nullableD = 2.0;
  final castedD = nullableD as double;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryTypeCastsRuleTest);
  });
}
