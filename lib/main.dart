import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:mvl_lint/src/rules/avoid_null_assertion.dart';

final plugin = MvlLintPlugin();

class MvlLintPlugin extends Plugin {
  @override
  String get name => 'mvl_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(AvoidNullAssertionRule());
  }
}
