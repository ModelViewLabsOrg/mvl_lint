import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:mvl_lint/src/utils/types_utils.dart';

class AvoidLateKeywordRule extends AnalysisRule {
  AvoidLateKeywordRule({
    this.allowInitialized = true,
    this.ignoredTypes = const {'AnimationController'},
  }) : super(
         name: 'avoid_late_keyword',
         description: 'Avoid using the late keyword.',
       );

  final bool allowInitialized;
  final Set<String> ignoredTypes;

  static const code = LintCode(
    'avoid_late_keyword',
    'Avoid using the "late" keyword. It may result in runtime exceptions.',
    correctionMessage: 'Use nullable types or initialize the variable directly.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_late_keyword',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addVariableDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AvoidLateKeywordRule rule;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (!node.isLate) {
      return;
    }

    final DartType? variableType = node.declaredFragment?.element.type;
    if (hasIgnoredType(variableType, rule.ignoredTypes)) {
      return;
    }

    if (rule.allowInitialized && node.initializer != null) {
      return;
    }

    rule.reportAtNode(node);
  }
}
