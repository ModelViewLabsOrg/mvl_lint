import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mvl_lint/src/rules/no_empty_block.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class NoEmptyBlockRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoEmptyBlockRule();
    super.setUp();
  }

  void test_empty_function_body() async {
    await assertDiagnostics(
      r'''
void f() {}
''',
      [lint(9, 2)],
    );
  }

  void test_empty_catch_block() async {
    await assertDiagnostics(
      r'''
void f() {
  try {
    print('x');
  } catch (_) {}
}
''',
      [lint(49, 2)],
    );
  }

  void test_nonempty_block_is_allowed() async {
    await assertNoDiagnostics(r'''
void f() {
  print('hello');
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoEmptyBlockRuleTest);
  });
}
