import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

class AvoidGlobalStateRule extends AnalysisRule {
  AvoidGlobalStateRule()
    : super(
        name: 'avoid_global_state',
        description: 'Avoid top-level and static mutable variables.',
      );

  static const code = LintCode(
    'avoid_global_state',
    'Avoid variables that can be globally mutated.',
    correctionMessage: 'Prefer final or const variables, or use a state management solution.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_global_state',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addTopLevelVariableDeclaration(this, _Visitor(this))
      ..addFieldDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final VariableDeclaration variable in node.variables.variables) {
      if (_isPublicMutable(variable)) {
        rule.reportAtNode(variable);
      }
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!node.isStatic) {
      return;
    }

    for (final VariableDeclaration variable in node.fields.variables) {
      if (_isPublicMutable(variable)) {
        rule.reportAtNode(variable);
      }
    }
  }

  bool _isPublicMutable(VariableDeclaration variable) {
    final VariableElement? element = variable.declaredFragment?.element;
    if (element == null) {
      return false;
    }

    return !element.isFinal && !element.isConst && !element.isPrivate;
  }
}
