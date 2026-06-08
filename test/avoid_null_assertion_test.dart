import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/avoid_null_assertion.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class AvoidNullAssertionRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidNullAssertionRule();
    super.setUp();
  }

  void test_null_assertion_on_variable() async {
    await assertDiagnostics(
      r'''
void f(String? value) {
  print(value!);
}
''',
      [lint(37, 1)],
    );
  }

  void test_null_assertion_on_property() async {
    await assertDiagnostics(
      r'''
class User {
  String? name;
}

void f(User user) {
  print(user.name!);
}
''',
      [lint(69, 1)],
    );
  }

  void test_no_null_assertion() async {
    await assertNoDiagnostics(
      r'''
void f(String? value) {
  if (value != null) {
    print(value);
  }
}
''',
    );
  }

  void test_logical_not_is_allowed() async {
    await assertNoDiagnostics(
      r'''
void f(bool value) {
  if (!value) {
    print('false');
  }
}
''',
    );
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidNullAssertionRuleTest);
  });
}
