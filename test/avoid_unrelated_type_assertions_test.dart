import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_unrelated_type_assertions.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidUnrelatedTypeAssertionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnrelatedTypeAssertionsRule();
    super.setUp();
  }

  void test_unrelated_is_assertion() async {
    await assertDiagnostics(
      r'''
void f() {
  final testList = [1, 2, 3];
  final result = testList is List<String>;
}
''',
      [lint(58, 24)],
    );
  }

  void test_related_is_assertion_is_allowed() async {
    await assertNoDiagnostics(r'''
class A {}

class B extends A {}

void f() {
  final A a = B();
  if (a is B) return;
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnrelatedTypeAssertionsRuleTest);
  });
}
