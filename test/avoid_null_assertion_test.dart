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

  void test_null_assertion_in_conditional_expression() async {
    await assertDiagnostics(
      r'''
class Pocket {
  Object? geoLocation;
  String? infoLocation;
}

void f(Pocket pocket) {
  if (pocket.geoLocation == null && pocket.infoLocation!.isNotEmpty) {}
}
''',
      [lint(144, 1)],
    );
  }

  void test_null_assertion_in_argument_list() async {
    await assertDiagnostics(
      r'''
class GeoLocation {
  final double lat;
  final double lng;

  const GeoLocation(this.lat, this.lng);
}

class Site {
  GeoLocation? geoLocation;
}

void f(Site site) {
  final location = GeoLocation(site.geoLocation!.lat, site.geoLocation!.lng);
}
''',
      [lint(216, 1), lint(239, 1)],
    );
  }

  void test_null_assertion_in_validator_callback() async {
    await assertDiagnostics(
      r'''
String? validate(String? v) => v!.isEmpty ? 'required' : null;
''',
      [lint(32, 1)],
    );
  }

  void test_no_null_assertion() async {
    await assertNoDiagnostics(r'''
void f(String? value) {
  if (value != null) {
    print(value);
  }
}
''');
  }

  void test_logical_not_is_allowed() async {
    await assertNoDiagnostics(r'''
void f(bool value) {
  if (!value) {
    print('false');
  }
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidNullAssertionRuleTest);
  });
}
