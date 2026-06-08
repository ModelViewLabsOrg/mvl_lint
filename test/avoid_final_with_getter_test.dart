import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_final_with_getter.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidFinalWithGetterRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidFinalWithGetterRule();
    super.setUp();
  }

  void test_final_private_field_with_getter() async {
    await assertDiagnostics(
      r'''
class MyClass {
  final int _myField = 0;

  int get myField => _myField;
}
''',
      [lint(45, 28)],
    );
  }

  void test_public_field_without_getter() async {
    await assertNoDiagnostics(r'''
class MyClass {
  final int myField = 0;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidFinalWithGetterRuleTest);
  });
}
