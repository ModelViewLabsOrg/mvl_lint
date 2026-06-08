import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidNullAssertionRule extends AnalysisRule {
  AvoidNullAssertionRule()
    : super(
        name: 'avoid_null_assertion',
        description: 'Disallows the null assertion operator (!) on nullable values.',
      );

  static const code = LintCode(
    'avoid_null_assertion',
    'Avoid using the null assertion operator (!) on nullable values.',
    correctionMessage:
        'Use null-aware operators, explicit null checks, or provide a default value instead.',
    severity: DiagnosticSeverity.ERROR,
    uniqueName: 'LintCode.avoid_null_assertion',
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);
    registry.addPostfixExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type == TokenType.BANG) {
      rule.reportAtToken(node.operator);
    }
  }
}
