import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:mvl_lint/src/utils/types_utils.dart';

class PreferFirstRule extends AnalysisRule {
  PreferFirstRule()
    : super(
        name: 'prefer_first',
        description: 'Prefer first instead of elementAt(0) or [0].',
      );

  static const code = LintCode(
    'prefer_first',
    'Use first instead of accessing the element at zero index.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.prefer_first',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry
      ..addMethodInvocation(this, _MethodVisitor(this))
      ..addIndexExpression(this, _IndexVisitor(this));
  }
}

class _MethodVisitor extends SimpleAstVisitor<void> {
  _MethodVisitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isIterableOrSubclass(node.realTarget?.staticType)) {
      return;
    }
    if (node.methodName.name != 'elementAt') {
      return;
    }

    final NodeList<Argument> arguments = node.argumentList.arguments;
    if (arguments.isEmpty) {
      return;
    }
    final Argument arg = arguments.first;
    if (arg is IntegerLiteral && arg.value == 0) {
      rule.reportAtNode(node);
    }
  }
}

class _IndexVisitor extends SimpleAstVisitor<void> {
  _IndexVisitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitIndexExpression(IndexExpression node) {
    if (!isListOrSubclass(node.realTarget.staticType)) {
      return;
    }

    final Expression index = node.index;
    if (index is IntegerLiteral && index.value == 0) {
      rule.reportAtNode(node);
    }
  }
}
