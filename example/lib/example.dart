// Example violations for mvl_lint rules.
// Run `dart analyze` in the example/ directory to see diagnostics.

import 'package:mvl_lint_example/avoid_final_with_getter_example.dart';
import 'package:mvl_lint_example/avoid_global_state_example.dart';
import 'package:mvl_lint_example/avoid_late_keyword_example.dart';
import 'package:mvl_lint_example/avoid_null_assertion_example.dart';
import 'package:mvl_lint_example/avoid_return_variable_example.dart';
import 'package:mvl_lint_example/avoid_type_checks_example.dart';
import 'package:mvl_lint_example/avoid_unused_parameters_example.dart';
import 'package:mvl_lint_example/complexity_example.dart';
import 'package:mvl_lint_example/no_empty_block_example.dart';
import 'package:mvl_lint_example/no_equal_then_else_example.dart';
import 'package:mvl_lint_example/no_magic_number_example.dart';
import 'package:mvl_lint_example/number_of_parameters_example.dart';
import 'package:mvl_lint_example/prefer_early_return_example.dart';
import 'package:mvl_lint_example/prefer_first_last_example.dart';
import 'package:mvl_lint_example/wrong_class_name.dart';

void main() {
  AvoidFinalWithGetterExample();
  AvoidGlobalStateExample();
  AvoidLateKeywordExample();
  AvoidNullAssertionExample();
  AvoidReturnVariableExample();
  AvoidTypeChecksExample();
  AvoidUnusedParametersExample();
  ComplexityExample();
  NoEmptyBlockExample();
  NoEqualThenElseExample();
  NoMagicNumberExample();
  NumberOfParametersExample();
  PreferEarlyReturnExample();
  PreferFirstLastExample();
  WrongClassName();
}
