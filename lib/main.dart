import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:mvl_lint/src/rules/avoid_final_with_getter.dart';
import 'package:mvl_lint/src/rules/avoid_global_state.dart';
import 'package:mvl_lint/src/rules/avoid_late_keyword.dart';
import 'package:mvl_lint/src/rules/avoid_null_assertion.dart';
import 'package:mvl_lint/src/rules/avoid_unnecessary_return_variable.dart';
import 'package:mvl_lint/src/rules/avoid_unnecessary_type_assertions.dart';
import 'package:mvl_lint/src/rules/avoid_unnecessary_type_casts.dart';
import 'package:mvl_lint/src/rules/avoid_unrelated_type_assertions.dart';
import 'package:mvl_lint/src/rules/avoid_unused_parameters.dart';
import 'package:mvl_lint/src/rules/cyclomatic_complexity.dart';
import 'package:mvl_lint/src/rules/function_lines_of_code.dart';
import 'package:mvl_lint/src/rules/no_empty_block.dart';
import 'package:mvl_lint/src/rules/no_equal_then_else.dart';
import 'package:mvl_lint/src/rules/no_magic_number.dart';
import 'package:mvl_lint/src/rules/number_of_parameters.dart';
import 'package:mvl_lint/src/rules/prefer_early_return.dart';
import 'package:mvl_lint/src/rules/prefer_first.dart';
import 'package:mvl_lint/src/rules/prefer_last.dart';
import 'package:mvl_lint/src/rules/prefer_match_file_name.dart';

final plugin = MvlLintPlugin();

class MvlLintPlugin extends Plugin {
  @override
  String get name => 'mvl_lint';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerLintRule(AvoidNullAssertionRule())
      ..registerLintRule(AvoidFinalWithGetterRule())
      ..registerLintRule(AvoidGlobalStateRule())
      ..registerLintRule(AvoidLateKeywordRule())
      ..registerLintRule(AvoidUnnecessaryReturnVariableRule())
      ..registerLintRule(AvoidUnnecessaryTypeAssertionsRule())
      ..registerLintRule(AvoidUnnecessaryTypeCastsRule())
      ..registerLintRule(AvoidUnrelatedTypeAssertionsRule())
      ..registerLintRule(AvoidUnusedParametersRule())
      ..registerLintRule(CyclomaticComplexityRule())
      ..registerLintRule(FunctionLinesOfCodeRule())
      ..registerLintRule(NoEmptyBlockRule())
      ..registerLintRule(NoEqualThenElseRule())
      ..registerLintRule(NoMagicNumberRule())
      ..registerLintRule(NumberOfParametersRule())
      ..registerLintRule(PreferEarlyReturnRule())
      ..registerLintRule(PreferFirstRule())
      ..registerLintRule(PreferLastRule())
      ..registerLintRule(PreferMatchFileNameRule());
  }
}
