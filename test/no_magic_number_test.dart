import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/no_magic_number.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class NoMagicNumberRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoMagicNumberRule();
    super.setUp();
  }

  void test_magic_number_in_expression() async {
    await assertDiagnostics(
      r'''
double circumference(double radius) => 2 * 3.14 * radius;
''',
      [lint(39, 1), lint(43, 4)],
    );
  }

  void test_named_constant_is_allowed() async {
    await assertNoDiagnostics(r'''
const pi = 3.14;
const radiusToDiameterCoefficient = 2;

double circumference(double radius) =>
    radiusToDiameterCoefficient * pi * radius;
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoMagicNumberRuleTest);
  });
}
