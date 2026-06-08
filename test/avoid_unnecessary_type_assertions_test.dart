import 'package:analyzer/src/diagnostic/diagnostic.dart' as diag;
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_unnecessary_type_assertions.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidUnnecessaryTypeAssertionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryTypeAssertionsRule();
    super.setUp();
  }

  void test_unnecessary_is_check() async {
    await assertDiagnostics(
      r'''
void f() {
  final testList = [1.0, 2.0, 3.0];
  final result = testList is List<double>;
}
''',
      [
        error(diag.unnecessaryTypeCheckTrue, 64, 24),
        lint(64, 24),
      ],
    );
  }

  void test_necessary_is_check() async {
    await assertNoDiagnostics(r'''
class A {}

class B extends A {}

class C extends A {}

void f() {
  final A a = B();
  if (a is! C) return;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryTypeAssertionsRuleTest);
  });
}
